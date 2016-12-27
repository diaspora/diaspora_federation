module DiasporaFederation
  # +Entity+ is the base class for all other objects used to encapsulate data
  # for federation messages in the diaspora* network.
  # Entity fields are specified using a simple {PropertiesDSL DSL} as part of
  # the class definition.
  #
  # Any entity also provides the means to serialize itself and all nested
  # entities to XML (for deserialization from XML to +Entity+ instances, see
  # {Salmon::XmlPayload}).
  #
  # @abstract Subclass and specify properties to implement various entities.
  #
  # @example Entity subclass definition
  #   class MyEntity < Entity
  #     property :prop
  #     property :optional, default: false
  #     property :dynamic_default, default: -> { Time.now }
  #     property :another_prop, xml_name: :another_name
  #     entity :nested, NestedEntity
  #     entity :multiple, [OtherEntity]
  #   end
  #
  # @example Entity instantiation
  #   nentity = NestedEntity.new
  #   oe1 = OtherEntity.new
  #   oe2 = OtherEntity.new
  #
  #   entity = MyEntity.new(prop: 'some property',
  #                         nested: nentity,
  #                         multiple: [oe1, oe2])
  #
  # @note Entity properties can only be set during initialization, after that the
  #   entity instance becomes frozen and must not be modified anymore. Instances
  #   are intended to be immutable data containers, only.
  class Entity
    extend PropertiesDSL
    include Logging

    # Invalid XML characters
    # @see https://www.w3.org/TR/REC-xml/#charsets "Extensible Markup Language (XML) 1.0"
    INVALID_XML_REGEX = /[^\x09\x0A\x0D\x20-\uD7FF\uE000-\uFFFD\u{10000}-\u{10FFFF}]/

    # Initializes the Entity with the given attribute hash and freezes the created
    # instance it returns.
    #
    # After creation, the entity is validated against a Validator, if one is defined.
    # The Validator needs to be in the {DiasporaFederation::Validators} namespace and
    # named like "<EntityName>Validator". Only valid entities can be created.
    #
    # @see DiasporaFederation::Validators
    #
    # @note Attributes not defined as part of the class definition ({PropertiesDSL#property},
    #       {PropertiesDSL#entity}) get discarded silently.
    #
    # @param [Hash] data entity data
    # @return [Entity] new instance
    def initialize(data)
      logger.debug "create entity #{self.class} with data: #{data}"
      raise ArgumentError, "expected a Hash" unless data.is_a?(Hash)

      entity_data = self.class.resolv_aliases(data)
      validate_missing_props(entity_data)

      self.class.default_values.merge(entity_data).each do |name, value|
        instance_variable_set("@#{name}", instantiate_nested(name, nilify(value))) if setable?(name, value)
      end

      freeze
      validate
    end

    # Returns a Hash representing this Entity (attributes => values).
    # Nested entities are also converted to a Hash.
    # @return [Hash] entity data (mostly equal to the hash used for initialization).
    def to_h
      properties.map {|key, value|
        type = self.class.class_props[key]

        if type == String || value.nil?
          [key, value]
        elsif type.instance_of?(Class)
          [key, value.to_h]
        elsif type.instance_of?(Array)
          [key, value.map(&:to_h)]
        end
      }.to_h
    end

    # Returns the XML representation for this entity constructed out of
    # {http://www.rubydoc.info/gems/nokogiri/Nokogiri/XML/Element Nokogiri::XML::Element}s
    #
    # @see Nokogiri::XML::Node.to_xml
    # @see XmlPayload#pack
    #
    # @return [Nokogiri::XML::Element] root element containing properties as child elements
    def to_xml
      doc = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
      Nokogiri::XML::Element.new(self.class.entity_name, doc).tap do |root_element|
        enriched_properties.each do |name, value|
          add_property_to_xml(doc, root_element, name, value)
        end
      end
    end

    # Construct a new instance of the given Entity and populate the properties
    # with the attributes found in the XML.
    # Works recursively on nested Entities and Arrays thereof.
    #
    # @param [Nokogiri::XML::Element] root_node xml nodes
    # @return [Entity] instance
    def self.from_xml(root_node)
      raise ArgumentError, "only Nokogiri::XML::Element allowed" unless root_node.instance_of?(Nokogiri::XML::Element)
      raise InvalidRootNode, "'#{root_node.name}' can't be parsed by #{name}" unless root_node.name == entity_name

      populate_entity(root_node)
    end

    # Makes an underscored, lowercase form of the class name
    #
    # @see .entity_class
    #
    # @return [String] entity name
    def self.entity_name
      name.rpartition("::").last.tap do |word|
        word.gsub!(/(.)([A-Z])/, '\1_\2')
        word.downcase!
      end
    end

    # Transform the given String from the lowercase underscored version to a
    # camelized variant and returns the Class constant.
    #
    # @see .entity_name
    #
    # @param [String] entity_name "snake_case" class name
    # @return [Class] entity class
    def self.entity_class(entity_name)
      raise InvalidEntityName, "'#{entity_name}' is invalid" unless entity_name =~ /^[a-z]*(_[a-z]*)*$/
      class_name = entity_name.sub(/^[a-z]/, &:upcase)
      class_name.gsub!(/_([a-z])/) { Regexp.last_match[1].upcase }

      raise UnknownEntity, "'#{class_name}' not found" unless Entities.const_defined?(class_name)

      Entities.const_get(class_name)
    end

    # @return [String] string representation of this object
    def to_s
      "#{self.class.name.rpartition('::').last}#{":#{guid}" if respond_to?(:guid)}"
    end

    private

    def validate_missing_props(entity_data)
      missing_props = self.class.missing_props(entity_data)
      raise ValidationError, "missing required properties: #{missing_props.join(', ')}" unless missing_props.empty?
    end

    def setable?(name, val)
      type = self.class.class_props[name]
      return false if type.nil? # property undefined

      setable_string?(type, val) || setable_nested?(type, val) || setable_multi?(type, val)
    end

    def setable_string?(type, val)
      type == String && val.respond_to?(:to_s)
    end

    def setable_nested?(type, val)
      type.instance_of?(Class) && type.ancestors.include?(Entity) && (val.is_a?(Entity) || val.is_a?(Hash))
    end

    def setable_multi?(type, val)
      type.instance_of?(Array) && val.instance_of?(Array) &&
        (val.all? {|v| v.instance_of?(type.first) } || val.all? {|v| v.instance_of?(Hash) })
    end

    def nilify(value)
      return nil if value.respond_to?(:empty?) && value.empty? && !value.instance_of?(Array)
      value
    end

    def instantiate_nested(name, value)
      if value.instance_of?(Array)
        return value unless value.first.instance_of?(Hash)
        value.map {|hash| self.class.class_props[name].first.new(hash) }
      elsif value.instance_of?(Hash)
        self.class.class_props[name].new(value)
      else
        value
      end
    end

    def validate
      validator_name = "#{self.class.name.split('::').last}Validator"
      return unless Validators.const_defined? validator_name

      validator_class = Validators.const_get validator_name
      validator = validator_class.new self
      raise ValidationError, error_message(validator) unless validator.valid?
    end

    def error_message(validator)
      errors = validator.errors.map do |prop, rule|
        "property: #{prop}, value: #{public_send(prop).inspect}, rule: #{rule[:rule]}, with params: #{rule[:params]}"
      end
      "Failed validation for properties: #{errors.join(' | ')}"
    end

    # @return [Hash] hash with all properties
    def properties
      self.class.class_props.keys.each_with_object({}) do |prop, hash|
        hash[prop] = public_send(prop)
      end
    end

    def normalized_properties
      properties.map {|name, value| [name, self.class.class_props[name] == String ? value.to_s : value] }.to_h
    end

    # default: nothing to enrich
    def enriched_properties
      normalized_properties
    end

    def add_property_to_xml(doc, root_element, name, value)
      if value.is_a? String
        root_element << simple_node(doc, name, value)
      else
        # call #to_xml for each item and append to root
        [*value].compact.each do |item|
          child = item.to_xml
          root_element << child if child
        end
      end
    end

    # Create simple node, fill it with text and append to root
    def simple_node(doc, name, value)
      xml_name = self.class.xml_names[name]
      Nokogiri::XML::Element.new(xml_name ? xml_name.to_s : name, doc).tap do |node|
        node.content = value.gsub(INVALID_XML_REGEX, "\uFFFD") unless value.empty?
      end
    end

    # @param [Nokogiri::XML::Element] root_node xml nodes
    # @return [Entity] instance
    private_class_method def self.populate_entity(root_node)
      new(entity_data(root_node))
    end

    # @param [Nokogiri::XML::Element] root_node xml nodes
    # @return [Hash] entity data
    private_class_method def self.entity_data(root_node)
      class_props.map {|name, type|
        value = parse_element_from_node(name, type, root_node)
        [name, value] if value
      }.compact.to_h
    end

    # @param [String] name property name to parse
    # @param [Class] type target type to parse
    # @param [Nokogiri::XML::Element] root_node XML node to parse
    # @return [Object] parsed data
    private_class_method def self.parse_element_from_node(name, type, root_node)
      if type == String
        parse_string_from_node(name, root_node)
      elsif type.instance_of?(Array)
        parse_array_from_node(type.first, root_node)
      elsif type.ancestors.include?(Entity)
        parse_entity_from_node(type, root_node)
      end
    end

    # Create simple entry in data hash
    #
    # @param [String] name xml tag to parse
    # @param [Nokogiri::XML::Element] root_node XML root_node to parse
    # @return [String] data
    private_class_method def self.parse_string_from_node(name, root_node)
      node = root_node.xpath(name.to_s)
      node = root_node.xpath(xml_names[name].to_s) if node.empty?
      node.first.text if node.any?
    end

    # Create an entry in the data hash for the nested entity
    #
    # @param [Class] type target type to parse
    # @param [Nokogiri::XML::Element] root_node XML node to parse
    # @return [Entity] parsed child entity
    private_class_method def self.parse_entity_from_node(type, root_node)
      node = root_node.xpath(type.entity_name)
      type.from_xml(node.first) if node.any? && node.first.children.any?
    end

    # Collect all nested children of that type and create an array in the data hash
    #
    # @param [Class] type target type to parse
    # @param [Nokogiri::XML::Element] root_node XML node to parse
    # @return [Array<Entity>] array with parsed child entities
    private_class_method def self.parse_array_from_node(type, root_node)
      node = root_node.xpath(type.entity_name)
      node.select {|child| child.children.any? }.map {|child| type.from_xml(child) } unless node.empty?
    end

    # Raised, if entity is not valid
    class ValidationError < RuntimeError
    end

    # Raised, if the root node doesn't match the class name
    class InvalidRootNode < RuntimeError
    end

    # Raised, if the entity name in the XML is invalid
    class InvalidEntityName < RuntimeError
    end

    # Raised, if the entity contained within the XML cannot be mapped to a
    # defined {Entity} subclass.
    class UnknownEntity < RuntimeError
    end
  end
end
