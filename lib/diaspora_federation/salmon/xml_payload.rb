module DiasporaFederation
  module Salmon
    # +XmlPayload+ provides methods to wrap a XML-serialized {Entity} inside a
    # common XML structure that will become the payload for federation messages.
    #
    # The wrapper looks like so:
    #   <XML>
    #     <post>
    #       {data}
    #     </post>
    #   </XML>
    #
    # (The +post+ element is there for historic reasons...)
    module XmlPayload
      # Encapsulates an Entity inside the wrapping xml structure
      # and returns the XML Object.
      #
      # @param [Entity] entity subject
      # @return [Nokogiri::XML::Element] XML root node
      # @raise [ArgumentError] if the argument is not an Entity subclass
      # @deprecated
      def self.pack(entity)
        raise ArgumentError, "only instances of DiasporaFederation::Entity allowed" unless entity.is_a?(Entity)

        entity_xml = entity.to_xml
        doc = entity_xml.document
        wrap = Nokogiri::XML::Element.new("XML", doc)
        wrap_post = Nokogiri::XML::Element.new("post", doc)
        entity_xml.parent = wrap_post
        wrap << wrap_post

        wrap
      end

      # Extracts the Entity XML from the wrapping XML structure, parses the entity
      # XML and returns a new instance of the Entity that was packed inside the
      # given payload.
      #
      # @param [Nokogiri::XML::Element] xml payload XML root node
      # @return [Entity] re-constructed Entity instance
      # @raise [ArgumentError] if the argument is not an
      #   {http://www.rubydoc.info/gems/nokogiri/Nokogiri/XML/Element Nokogiri::XML::Element}
      # @raise [UnknownEntity] if the class for the entity contained inside the
      #   XML can't be found
      def self.unpack(xml)
        raise ArgumentError, "only Nokogiri::XML::Element allowed" unless xml.instance_of?(Nokogiri::XML::Element)

        data = xml_wrapped?(xml) ? xml.at_xpath("post/*[1]") : xml
        klass_name = entity_class_name(data.name)
        raise Salmon::UnknownEntity, "'#{klass_name}' not found" unless Entities.const_defined?(klass_name)

        klass = Entities.const_get(klass_name)
        populate_entity(klass, data)
      end

      # @param [Nokogiri::XML::Element] element
      # @deprecated
      def self.xml_wrapped?(element)
        (element.name == "XML" && !element.at_xpath("post").nil? &&
         !element.at_xpath("post").children.empty?)
      end
      private_class_method :xml_wrapped?

      # Transform the given String from the lowercase underscored version to a
      # camelized variant, used later for getting the Class constant.
      #
      # @param [String] term "snake_case" class name
      # @return [String] "CamelCase" class name
      def self.entity_class_name(term)
        term.to_s.tap do |string|
          raise Salmon::InvalidEntityName, "'#{string}' is invalid" unless string =~ /^[a-z]*(_[a-z]*)*$/
          string.sub!(/^[a-z]/, &:upcase)
          string.gsub!(/_([a-z])/) { Regexp.last_match[1].upcase }
        end
      end
      private_class_method :entity_class_name

      # Construct a new instance of the given Entity and populate the properties
      # with the attributes found in the XML.
      # Works recursively on nested Entities and Arrays thereof.
      #
      # @param [Class] klass entity class
      # @param [Nokogiri::XML::Element] root_node xml nodes
      # @return [Entity] instance
      def self.populate_entity(klass, root_node)
        # Use all known properties to build the Entity (entity_data). All additional xml elements
        # are respected and attached to a hash as string (additional_xml_elements). It is intended
        # to build a hash invariable of an Entity definition, in order to support receiving objects
        # from the future versions of Diaspora, where new elements may have been added.
        entity_data = {}
        additional_xml_elements = {}

        root_node.element_children.each do |child|
          xml_name = child.name
          property = klass.find_property_for_xml_name(xml_name)

          if property
            entity_data[property] = parse_element_from_node(klass.class_props[property], xml_name, root_node)
          else
            additional_xml_elements[xml_name] = child.text
          end
        end

        klass.new(entity_data, additional_xml_elements).tap do |entity|
          entity.verify_signatures if entity.respond_to? :verify_signatures
        end
      end
      private_class_method :populate_entity

      # @param [Class] type target type to parse
      # @param [String] xml_name xml tag to parse
      # @param [Nokogiri::XML::Element] node XML node to parse
      # @return [Object] parsed data
      def self.parse_element_from_node(type, xml_name, node)
        if type == String
          parse_string_from_node(xml_name, node)
        elsif type.instance_of?(Array)
          parse_array_from_node(type, node)
        elsif type.ancestors.include?(Entity)
          parse_entity_from_node(type, node)
        end
      end
      private_class_method :parse_element_from_node

      # create simple entry in data hash
      #
      # @param [String] name xml tag to parse
      # @param [Nokogiri::XML::Element] root_node XML root_node to parse
      # @return [String] data
      def self.parse_string_from_node(name, root_node)
        node = root_node.xpath(name.to_s)
        node.first.text if node.any?
      end
      private_class_method :parse_string_from_node

      # create an entry in the data hash for the nested entity
      #
      # @param [Class] type target type to parse
      # @param [Nokogiri::XML::Element] root_node XML node to parse
      # @return [Entity] parsed child entity
      def self.parse_entity_from_node(type, root_node)
        node = root_node.xpath(type.entity_name)
        populate_entity(type, node.first) if node.any?
      end
      private_class_method :parse_entity_from_node

      # collect all nested children of that type and create an array in the data hash
      #
      # @param [Array<Class>] type target type to parse
      # @param [Nokogiri::XML::Element] root_node XML node to parse
      # @return [Array<Entity>] array with parsed child entities
      def self.parse_array_from_node(type, root_node)
        node = root_node.xpath(type.first.entity_name)
        node.map {|child| populate_entity(type.first, child) }
      end
      private_class_method :parse_array_from_node
    end
  end
end
