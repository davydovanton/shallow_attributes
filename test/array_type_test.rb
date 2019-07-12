require 'test_helper'

describe ShallowAttributes::Type::Array do
  describe '#coerce' do
    let(:type) { ShallowAttributes::Type::Array.new }

    describe 'when value is not Array' do
      it 'returns InvalidValueError' do
        err = -> { type.coerce('test', of: Integer) }.must_raise ShallowAttributes::Type::InvalidValueError
        err.message.must_equal %(Invalid value "test" for type "Array")

        err = -> { type.coerce(123, of: Integer) }.must_raise ShallowAttributes::Type::InvalidValueError
        err.message.must_equal %(Invalid value "123" for type "Array")

        err = -> { type.coerce(true, of: Integer) }.must_raise ShallowAttributes::Type::InvalidValueError
        err.message.must_equal %(Invalid value "true" for type "Array")

        err = -> { type.coerce({a: :b}, of: Integer) }.must_raise ShallowAttributes::Type::InvalidValueError
        err.message.must_equal %(Invalid value "{:a=>:b}" for type "Array")

        err = -> { type.coerce(Class) }.must_raise ShallowAttributes::Type::InvalidValueError
        err.message.must_equal %(Invalid value "Class" for type "Array")

        err = -> { type.coerce(Class.new) }.must_raise ShallowAttributes::Type::InvalidValueError
        err.message.must_match 'Invalid value "#<Class:'
        err.message.must_match '" for type "Array"'
      end
    end

    describe 'when value is Array of specified types' do
      let(:arbitrary_class) { Class.new }
      let(:arbitrary_value) { arbitrary_class.new }

      it 'returns array of non-coerced values' do
        type.coerce([arbitrary_value], of: arbitrary_class).must_equal [arbitrary_value]
      end
    end

    describe 'when value is Array of non-specified types' do
      it 'returns array of specific type' do
        type.coerce([], of: Integer).must_equal []
        type.coerce(['1', '2'], of: Integer).must_equal [1, 2]
        type.coerce([true, false], of: Integer).must_equal [1, 0]
        type.coerce(['1', '2'], of: 'Integer').must_equal [1, 2]
      end
    end
  end
end
