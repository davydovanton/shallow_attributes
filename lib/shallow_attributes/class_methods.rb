module ShallowAttributes
  # Abstract class for value classes. Provides some helper methods for
  # working with class methods.
  #
  # @abstract
  #
  # @since 0.1.0
  module ClassMethods
    # Inject our default values into subclasses.
    #
    # @private
    #
    # @param [Object] subclass
    #
    def inherited(subclass)
      super
      if respond_to?(:descriptions)
        subclass.descriptions.merge!(descriptions)
      end

      if respond_to?(:formats)
        subclass.formats.merge!(formats)
      end

      if respond_to?(:default_values)
        subclass.default_values.merge!(default_values)
      end
    end

    # Returns hash that contains default values for each attribute
    #
    # @private
    #
    # @return [Hash] hash with default values
    #
    # @since 0.1.0
    def default_values
      @default_values ||= {}
    end

    # Returns hash that contains mandatory attributes
    #
    # @private
    #
    # @return [Hash] hash with mandatory attributes
    #
    # @since 0.10.0
    def mandatory_attributes
      @mandatory_attributes ||= {}
    end

    def descriptions
      @descriptions ||= {}
    end

    def formats
      @formats ||= {}
    end

    # Returns all class attributes.
    #
    # @example Create new User instance
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String
    #     attribute :last_name, String
    #     attribute :age, Integer
    #   end
    #
    #   User.attributes # => [:name, :last_name, :age]
    #
    # @return [Hash]
    #
    # @since 0.1.0
    def attributes
      default_values.keys
    end

    # Define attribute with specific type and default value
    # for current class.
    #
    # @param [String, Symbol] name the attribute name
    # @param [String, Symbol] type the type of attribute
    # @param [hash] options the attribute options
    # @option options [Object] :default default value for attribute
    # @option options [Class] :of class of array elems
    # @option options [boolean] :allow_nil cast `nil` to integer or float
    # @option options [boolean] :present raise error if attribute was not provided
    #
    # @example Create new User instance
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String, default: 'Anton'
    #   end
    #
    #   User.new              # => #<User @attributes={:name=>"Anton"}, @name="Anton">
    #   User.new(name: 'ben') # => #<User @attributes={:name=>"Ben"}, @name="Ben">
    #
    # @return [Object]
    #
    # @since 0.1.0
    def attribute(name, type, options = {})
      options[:default] ||= [] if type == Array

      default_values[name] = options.delete(:default)
      mandatory_attributes[name] = options.delete(:present)
      descriptions[name] = options.delete(:desc)
      formats[name] = options.delete(:format)

      initialize_setter(name, type, options)
      initialize_getter(name)
    end

    private

    # Define setter method for each attribute.
    #
    # @private
    #
    # @param [String, Symbol] name the attribute name
    # @param [String, Symbol] type the type of attribute
    # @param [hash] options the attribute options
    #
    # @return [Object]
    #
    # @since 0.1.0
    def initialize_setter(name, type, options)
      type_class = dry_type?(type) ? type.class : type

      module_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{name}=(value)
          @#{name} = if value.is_a?(#{type_class}) && !value.is_a?(Array)
            value
          else
            #{type_casting(type, options)}
          end

          @attributes[:#{name}] = @#{name}
        end
      EOS
    end

    # Define getter method for each attribute.
    #
    # @private
    #
    # @param [String, Symbol] name the attribute name
    #
    # @return [Object]
    #
    # @since 0.1.0
    def initialize_getter(name)
      attr_reader name
    end

    private

    DRY_TYPE_CLASS = 'Dry::Types'.freeze

    # Check type with dry-type
    #
    # @private
    #
    # @param [Class] type the class of type
    #
    # @return [Bool]
    #
    # @since 0.2.0
    def dry_type?(type)
      type.class.name.match(DRY_TYPE_CLASS)
    end

    # Returns string for type casting
    #
    # @private
    #
    # @param [Class] type the class of type
    # @param [Hash] options the options
    #
    # @return [String]
    #
    # @since 0.2.0
    def type_casting(type, options)
      if dry_type?(type)
        # yep, I know that it's terrible line but it was the easily
        # way to type cast data with dry-types from class method in instance method
        "ObjectSpace._id2ref(#{type.object_id})[value]"
      else
        "ShallowAttributes::Type.coerce(#{type}, value, #{options})"
      end
    end
  end
end
