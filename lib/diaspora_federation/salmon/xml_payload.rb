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
    # @deprecated
    module XmlPayload
      # Encapsulates an Entity inside the wrapping xml structure
      # and returns the XML Object.
      #
      # @param [Entity] entity subject
      # @return [Nokogiri::XML::Element] XML root node
      # @raise [ArgumentError] if the argument is not an Entity subclass
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

        Entity.entity_class(data.name).from_xml(data)
      end

      # @param [Nokogiri::XML::Element] element
      def self.xml_wrapped?(element)
        (element.name == "XML" && !element.at_xpath("post").nil? &&
         !element.at_xpath("post").children.empty?)
      end
      private_class_method :xml_wrapped?
    end
  end
end
