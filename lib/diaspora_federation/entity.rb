module DiasporaFederation
  # +Entity+ is the base class for all other objects used to encapsulate data
  # for federation messages in the Diaspora* network.
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
    # @param [Hash] data
    # @return [Entity] new instance
    def initialize(data)
      raise ArgumentError, "expected a Hash" unless data.is_a?(Hash)
      missing_props = self.class.missing_props(data)
      unless missing_props.empty?
        raise ArgumentError, "missing required properties: #{missing_props.join(', ')}"
      end

      self.class.default_values.merge(data).each do |k, v|
        instance_variable_set("@#{k}", nilify(v)) if setable?(k, v)
      end

      freeze
      validate
    end

    # Returns a Hash representing this Entity (attributes => values)
    # @return [Hash] entity data (mostly equal to the hash used for initialization).
    def to_h
      self.class.class_prop_names.each_with_object({}) do |prop, hash|
        hash[prop] = public_send(prop)
      end
    end

    # Returns the XML representation for this entity constructed out of
    # {http://www.rubydoc.info/gems/nokogiri/Nokogiri/XML/Element Nokogiri::XML::Element}s
    #
    # @see Nokogiri::XML::Node.to_xml
    # @see Salmon::XmlPayload.pack
    #
    # @return [Nokogiri::XML::Element] root element containing properties as child elements
    def to_xml
      entity_xml
    end

    # Makes an underscored, lowercase form of the class name
    # @return [String] entity name
    def self.entity_name
      name.rpartition("::").last.tap do |word|
        word.gsub!(/(.)([A-Z])/, '\1_\2')
        word.downcase!
      end
    end

    private

    def setable?(name, val)
      prop_def = self.class.class_props.find {|p| p[:name] == name }
      return false if prop_def.nil? # property undefined

      setable_string?(prop_def, val) || setable_nested?(prop_def, val) || setable_multi?(prop_def, val)
    end

    def setable_string?(definition, val)
      (definition[:type] == String && val.respond_to?(:to_s))
    end

    def setable_nested?(definition, val)
      t = definition[:type]
      (t.is_a?(Class) && t.ancestors.include?(Entity) && val.is_a?(Entity))
    end

    def setable_multi?(definition, val)
      t = definition[:type]
      (t.instance_of?(Array) &&
        val.instance_of?(Array) &&
        val.all? {|v| v.instance_of?(t.first) })
    end

    def nilify(value)
      return nil if value.respond_to?(:empty?) && value.empty?
      value
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

    # Serialize the Entity into XML elements
    # @return [Nokogiri::XML::Element] root node
    def entity_xml
      doc = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
      Nokogiri::XML::Element.new(self.class.entity_name, doc).tap do |root_element|
        self.class.class_props.each do |prop_def|
          add_property_to_xml(doc, prop_def, root_element)
        end
      end
    end

    def add_property_to_xml(doc, prop_def, root_element)
      property = prop_def[:name]
      type = prop_def[:type]
      if type == String
        root_element << simple_node(doc, prop_def[:xml_name], property)
      else
        # call #to_xml for each item and append to root
        [*public_send(property)].compact.each do |item|
          root_element << item.to_xml
        end
      end
    end

    # create simple node, fill it with text and append to root
    def simple_node(doc, name, property)
      Nokogiri::XML::Element.new(name.to_s, doc).tap do |node|
        data = public_send(property).to_s
        node.content = data unless data.empty?
      end
    end

    # Raised, if entity is not valid
    class ValidationError < RuntimeError
    end
  end
end
