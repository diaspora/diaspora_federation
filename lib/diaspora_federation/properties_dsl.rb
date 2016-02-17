module DiasporaFederation
  # Provides a simple DSL for specifying {Entity} properties during class
  # definition.
  #
  # @example
  #   property :prop
  #   property :optional, default: false
  #   property :dynamic_default, default: -> { Time.now }
  #   property :another_prop, xml_name: :another_name
  #   property :original_prop, alias: :alias_prop
  #   entity :nested, NestedEntity
  #   entity :multiple, [OtherEntity]
  module PropertiesDSL
    # @return [Hash] hash of declared entity properties
    def class_props
      @class_props ||= {}
    end

    # Define a generic (string-type) property
    # @param [Symbol] name property name
    # @param [Hash] opts further options
    # @option opts [Object, #call] :default a default value, making the
    #   property optional
    # @option opts [Symbol] :xml_name another name used for xml generation
    def property(name, opts={})
      define_property name, String, opts
    end

    # Define a property that should contain another Entity or an array of
    # other Entities
    # @param [Symbol] name property name
    # @param [Entity, Array<Entity>] type Entity subclass or
    #                Array with exactly one Entity subclass constant inside
    # @param [Hash] opts further options
    # @option opts [Object, #call] :default a default value, making the
    #   property optional
    def entity(name, type, opts={})
      raise InvalidType unless type_valid?(type)

      define_property name, type, opts
    end

    # Return array of missing required property names
    # @return [Array<Symbol>] missing required property names
    def missing_props(args)
      class_props.keys - default_props.keys - args.keys
    end

    # Return a new hash of default values, with dynamic values
    # resolved on each call
    # @return [Hash] default values
    def default_values
      default_props.each_with_object({}) {|(name, prop), hash|
        hash[name] = prop.respond_to?(:call) ? prop.call : prop
      }
    end

    # @param [Hash] data entity data
    # @return [Hash] hash with resolved aliases
    def resolv_aliases(data)
      Hash[data.map {|name, value|
        if class_prop_aliases.has_key? name
          prop_name = class_prop_aliases[name]
          raise InvalidData, "only use '#{name}' OR '#{prop_name}'" if data.has_key? prop_name
          [prop_name, value]
        else
          [name, value]
        end
      }]
    end

    # @return [Symbol] alias for the xml-generation/parsing
    # @deprecated
    def xml_names
      @xml_names ||= {}
    end

    # finds a property by +xml_name+ or +name+
    # @param [String] xml_name name of the property from the received xml
    # @return [Hash] the property data
    def find_property_for_xml_name(xml_name)
      class_props.keys.find {|name| name.to_s == xml_name || xml_names[name].to_s == xml_name }
    end

    private

    # @deprecated
    def determine_xml_name(name, type, opts={})
      raise ArgumentError, "xml_name is not supported for nested entities" if type != String && opts.has_key?(:xml_name)

      if type == String
        if opts.has_key? :xml_name
          raise InvalidName, "invalid xml_name" unless name_valid?(opts[:xml_name])
          opts[:xml_name]
        else
          name
        end
      elsif type.instance_of?(Array)
        type.first.entity_name.to_sym
      elsif type.ancestors.include?(Entity)
        type.entity_name.to_sym
      end
    end

    def define_property(name, type, opts={})
      raise InvalidName unless name_valid?(name)

      class_props[name] = type
      default_props[name] = opts[:default] if opts.has_key? :default
      xml_names[name] = determine_xml_name(name, type, opts)

      instance_eval { attr_reader name }

      define_alias(name, opts[:alias]) if opts.has_key? :alias
    end

    # checks if the name is a +Symbol+ or a +String+
    # @param [String, Symbol] name the name to check
    # @return [Boolean]
    def name_valid?(name)
      name.instance_of?(Symbol)
    end

    # checks if the type extends {Entity}
    # @param [Class] type the type to check
    # @return [Boolean]
    def type_valid?(type)
      [type].flatten.all? {|type|
        type.respond_to?(:ancestors) && type.ancestors.include?(Entity)
      }
    end

    def default_props
      @default_props ||= {}
    end

    # Returns all alias mappings
    # @return [Hash] alias properties
    def class_prop_aliases
      @class_prop_aliases ||= {}
    end

    # @param [Symbol] name property name
    # @param [Symbol] alias_name alias name
    def define_alias(name, alias_name)
      class_prop_aliases[alias_name] = name
      instance_eval { alias_method alias_name, name }
    end

    # Raised, if the name is of an unexpected type
    class InvalidName < RuntimeError
    end

    # Raised, if the type is of an unexpected type
    class InvalidType < RuntimeError
    end

    # Raised, if the data contains property twice (with name AND alias)
    class InvalidData < RuntimeError
    end
  end
end
