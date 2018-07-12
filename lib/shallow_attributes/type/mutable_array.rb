module ShallowAttributes
  module Type
    # Class for mutable arrays.
    #
    # @abstract
    #
    # @since 0.9.1
    class MutableArray < ::Array
      def initialize(items = [], of: nil)
        @of = of
        super(
          items.map { |item| ShallowAttributes::Type.coerce(item_class, item) }
        )
      end

      def <<(item)
        super ShallowAttributes::Type.coerce(item_class, item)
      end

      def push(*items)
        super(
          *items.map { |item| ShallowAttributes::Type.coerce(item_class, item) }
        )
      end

      def concat(other)
        super(
          other.map { |item| ShallowAttributes::Type.coerce(item_class, item) }
        )
      end

      def replace(other)
        super(
          other.map { |item| ShallowAttributes::Type.coerce(item_class, item) }
        )
      end

      private

      def item_class
        return @of unless @of.is_a? ::String
        Object.const_get(@of)
      end
    end
  end
end
