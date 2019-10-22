require 'test_helper'

class City
  include ShallowAttributes

  attribute :name, String
  attribute :size, Integer, default: 9000
end

class Address
  include ShallowAttributes

  attribute :street,  String
  attribute :zipcode, String, default: '111111'
  attribute :city,    City
end

class Person
  include ShallowAttributes

  attribute :name,      String
  attribute :address,   Address
  attribute :addresses, Array, of: Address
end

describe ShallowAttributes do
  describe 'with custom types' do
    let(:person) do
      Person.new(address: {
        street: 'Street 1/2', city: {
          name: 'NYC'
        }
      })
    end

    it 'allows embedded values' do
      person.address.zipcode.must_equal '111111'
      person.address.street.must_equal 'Street 1/2'
      person.address.city.size.must_equal 9000
      person.address.city.name.must_equal 'NYC'
    end

    it 'returns normal hash' do
      person.address.zipcode.must_equal '111111'
      person.address.street.must_equal 'Street 1/2'
      person.address.city.size.must_equal 9000
      person.address.city.name.must_equal 'NYC'
    end

    it 'builds the custom types with the correct class' do
      person.address.must_be_instance_of Address
      person.address.city.must_be_instance_of City
    end

    it 'does not change the attribute type after call the method #attributes' do
      person.attributes
      person.address.must_be_instance_of Address
    end

    describe 'when one of attribute is array' do
      let(:person) { Person.new addresses: [address_1, address_2] }
      let(:address_1) do
        {
          street: 'Street 1/2',
          city: {
            name: 'NYC'
          }
        }
      end
      let(:address_2) do
        {
          street: 'Street 3/2',
          city: {
            name: 'Moscow'
          }
        }
      end

      it 'allows embedded values' do
        person.addresses.count.must_equal 2

        person.addresses[0].street.must_equal 'Street 1/2'
        person.addresses[0].city.name.must_equal 'NYC'

        person.addresses[1].street.must_equal 'Street 3/2'
        person.addresses[1].city.name.must_equal 'Moscow'
      end

      it 'allows change embedded values' do
        person.addresses[0].city.name = 'LA'
        person.addresses[0].city.name.must_equal 'LA'

        person.addresses[1].city.name = 'Spb'
        person.addresses[1].city.name.must_equal 'Spb'
      end

      it 'builds the custom types with the correct class' do
        person.addresses[0].must_be_instance_of Address
        person.addresses[0].city.must_be_instance_of City
      end

      it 'does not change the attribute type after call the method #attributes' do
        person.attributes
        person.addresses[0].must_be_instance_of Address
      end

      describe 'array of ShallowAttributes objects' do
        let(:address_1) do
          Address.new(
            street: 'Street 1/2',
            city: {
              name: 'NYC'
            }
          )
        end
        let(:address_2) do
          Address.new(
            street: 'Street 3/2',
            city: {
              name: 'Moscow'
            }
          )
        end

        it 'allows embedded ShallowAttributes objects' do
          person.addresses.count.must_equal 2

          person.addresses[0].street.must_equal 'Street 1/2'
          person.addresses[0].city.name.must_equal 'NYC'

          person.addresses[1].street.must_equal 'Street 3/2'
          person.addresses[1].city.name.must_equal 'Moscow'
        end
      end

      describe '#attributes' do
        it 'returns attributes hash' do
          hash = person.attributes
          hash.must_equal(addresses: [
            {
              zipcode: '111111',
              street: 'Street 1/2',
              city: {
                size: 9000,
                name: 'NYC'
              }
            },
            {
              zipcode: '111111',
              street: 'Street 3/2',
              city: {
                size: 9000,
                name: 'Moscow'
              }
            }
          ])
        end

        it 'returns changed attributes hash' do
          person.addresses[0].city.name = 'LA'
          hash = person.attributes
          hash.must_equal(addresses: [
            {
              zipcode: '111111',
              street: 'Street 1/2',
              city: {
                size: 9000,
                name: 'LA'
              }
            },
            {
              zipcode: '111111',
              street: 'Street 3/2',
              city: {
                size: 9000,
                name: 'Moscow'
              }
            }
          ])
        end
      end
    end
  end
end
