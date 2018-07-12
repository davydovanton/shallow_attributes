module ShallowAttributes
  module Type
    # Abstract class for typecast object to Array type.
    #
    # @abstract
    #
    # @since 0.1.0
    class Array
      # Convert value to Array type
      #
      # @private
      #
      # @param [Array] values
      # @param [Hash] options
      # @option options [String] :of the type of array element class
      #
      # @example Convert integer array to string array
      #   ShallowAttributes::Type::Array.new.coerce([1, 2], String)
      #     # => ['1', '2']
      #
      # @raise [InvalidValueError] if value is not an Array
      #
      # @return [Array]
      #
      # @since 0.1.0
      def coerce(values, options = {})
        unless values.is_a? ::Array
          raise ShallowAttributes::Type::InvalidValueError, %(Invalid value "#{values}" for type "Array")
        end
        MutableArray.new(values, **options)
      end
    end
  end
end
