require 'shallow_attributes/type/array'
require 'shallow_attributes/type/boolean'
require 'shallow_attributes/type/date_time'
require 'shallow_attributes/type/float'
require 'shallow_attributes/type/integer'
require 'shallow_attributes/type/string'
require 'shallow_attributes/type/time'
require 'shallow_attributes/type/date'

# Boolean class for working with bool values
#
# @private
#
# @since 0.9.4
class Boolean; end

module ShallowAttributes
  # Namespace for standard type classes
  #
  # @since 0.1.0
  module Type
    # Error class for invalid value types
    #
    # @since 0.1.0
    class InvalidValueError < TypeError
    end

    # Hash object with cached type objects.
    #
    # @private
    #
    # @since 0.1.0
    DEFAULT_TYPE_OBJECTS = {
      ::Array    => ShallowAttributes::Type::Array.new,
      ::DateTime => ShallowAttributes::Type::DateTime.new,
      ::Float    => ShallowAttributes::Type::Float.new,
      ::Integer  => ShallowAttributes::Type::Integer.new,
      ::String   => ShallowAttributes::Type::String.new,
      ::Time     => ShallowAttributes::Type::Time.new,
      ::Date     => ShallowAttributes::Type::Date.new,
      ::Boolean     => ShallowAttributes::Type::Boolean.new
    }.freeze

    class << self
      # Convert value object to specific Type class
      #
      # @private
      #
      # @param [Class] type the type class object
      # @param [Object] value the value that should be coerced to the necessary type
      # @param [Hash] options the options to create a message with.
      # @option options [String] :of The type of array
      # @option options [boolean] :allow_nil cast `nil` to integer or float
      #
      # @example Convert integer to sting type
      #   ShallowAttributes::Type.coerce(String, 1)
      #     # => '1'
      #
      # @example Convert string to custom hash type
      #   ShallowAttributes::Type.instance_for(JsonType, '{"a"=>1}')
      #     # => { a: 1 }
      #
      # @return the converted value object
      #
      # @since 0.1.0
      def coerce(type, value, options = {})
        instance = type_instance(type, value)
        return instance.coerce(instance.attributes, options) if instance.respond_to? :attributes

        instance.coerce(value, options)
      end

    private

      # Returns class object for specific Type class
      #
      # @private
      #
      # @param [Class] klass the type class object
      #
      # @example Returns Sting type class
      #   ShallowAttributes::Type.instance_for(String)
      #     # => ShallowAttributes::Type::Sting class
      #
      # @example Returns other type class
      #   ShallowAttributes::Type.instance_for(MySpecialStringType)
      #     # => MySpecialStringType class
      #
      # @return [Class]
      #
      # @since 0.1.0
      def type_instance(klass, value = {})
        return DEFAULT_TYPE_OBJECTS[klass] if DEFAULT_TYPE_OBJECTS[klass]

        instantiable = ShallowAttributes::Type.const_get(klass.name)

        return instantiable.new(value) if instantiable < ShallowAttributes

        instantiable.new
      end
    end
  end
end
