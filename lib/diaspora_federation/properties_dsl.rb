module DiasporaFederation
  # Provides a simple DSL for specifying {Entity} properties during class
  # definition.
  #
  # @example
  #   property :prop
  #   property :optional, default: false
  #   property :dynamic_default, default: -> { Time.now }
  #   property :another_prop, xml_name: :another_name
  #   entity :nested, NestedEntity
  #   entity :multiple, [OtherEntity]
  module PropertiesDSL
    # @return [Array<Hash>] hash of declared entity properties
    def class_props
      @class_props ||= []
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
      class_prop_names - default_props.keys - args.keys
    end

    # Return a new hash of default values, with dynamic values
    # resolved on each call
    # @return [Hash] default values
    def default_values
      default_props.each_with_object({}) {|(name, prop), hash|
        hash[name] = prop.respond_to?(:call) ? prop.call : prop
      }
    end

    # Returns all nested Entities
    # @return [Array<Hash>] nested properties
    def nested_class_props
      @nested_class_props ||= class_props.select {|p| p[:type] != String }
    end

    # Returns all property names
    # @return [Array] property names
    def class_prop_names
      @class_prop_names ||= class_props.map {|p| p[:name] }
    end

    # finds a property by +xml_name+ or +name+
    # @param [String] xml_name name of the property from the received xml
    # @return [Hash] the property data
    def find_property_for_xml_name(xml_name)
      class_props.find {|prop| prop[:xml_name].to_s == xml_name || prop[:name].to_s == xml_name }
    end

    private

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

      class_props << {name: name, xml_name: determine_xml_name(name, type, opts), type: type}
      default_props[name] = opts[:default] if opts.has_key? :default

      instance_eval { attr_reader name }
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

    # Raised, if the name is of an unexpected type
    class InvalidName < RuntimeError
    end

    # Raised, if the type is of an unexpected type
    class InvalidType < RuntimeError
    end
  end
end
