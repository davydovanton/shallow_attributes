require 'test_helper'

class SimpleUser
  include ShallowAttributes
  attribute :name, String, defauil: 'Ben'
end

class UserWithPresentName
  include ShallowAttributes
  attribute :name, String, present: true
end

class MainUser
  include ShallowAttributes

  attribute :name, String, default: 'Ben'
  attribute :last_name, String, default: :default_last_name
  attribute :full_name, String, default: -> (user, attribute) { "#{user.name} #{user.last_name}" }
  attribute :age, Integer
  attribute :birthday, DateTime

  attribute :friends_count, Integer, default: 0
  attribute :sizes, Array, of: Integer

  attribute :admin, Boolean, default: false

  def default_last_name
    'Affleck'
  end
end

describe ShallowAttributes do
  let(:user) { MainUser.new(name: 'Anton', age: 22) }

  describe '::attributes' do
    it 'returns class attributes array' do
      MainUser.attributes.must_equal(%i(name last_name full_name age birthday friends_count sizes admin))
    end
  end

  describe 'on initialize' do
    let(:user) { MainUser.new }

    it 'builds getters for each attribute' do
      assert_nil user.age
      assert_nil user.birthday
      user.sizes.must_equal []
    end

    it 'builds setter for attribute' do
      user.name = 'Anton'
      user.name.must_equal 'Anton'

      user.age = 22
      user.age.must_equal 22
    end

    it 'sets attributes from symbolized hash' do
      user = MainUser.new(name: 'Anton', age: 22)

      user.name.must_equal 'Anton'
      user.age.must_equal 22
    end

    it 'sets attributes from stringified hash' do
      user = MainUser.new('name' => 'Anton', 'age' => 22)

      user.name.must_equal 'Anton'
      user.age.must_equal 22
    end

    it 'does not mutate the argument' do
      params = {'name' => 'Anton', 'age' => 22}
      MainUser.new(params)
      params.must_equal({'name' => 'Anton', 'age' => 22})
    end

    it 'sets object as default value for each attribute' do
      user.name.must_equal 'Ben'
      user.friends_count.must_equal 0
      user.admin.must_equal false
    end

    it 'sets method name as default value for each attribute' do
      user.last_name.must_equal 'Affleck'
    end

    it 'sets lambda as default value for each attribute' do
      user.full_name.must_equal 'Ben Affleck'
    end

    describe 'when present option set' do
      it 'raises error for not present attribute' do
        proc {
          UserWithPresentName.new
        }.must_raise NotPresentError
      end

      it 'works fine for present attribute' do
        UserWithPresentName.new(name: 'Anton')
      end
    end

    describe 'with array type' do
      it 'initializes array of objects' do
        user = MainUser.new(sizes: %w[1 2 3])
        user.sizes.must_equal [1, 2, 3]
      end

      it 'builds setter for array attribute' do
        user = MainUser.new
        user.sizes = %w[1 2 3]

        user.sizes.must_equal [1, 2, 3]
      end
    end
  end

  describe '#attributes=' do
    it 'mass-assignments from symbolized hash' do
      user.attributes = { name: 'Alex' }

      user.name.must_equal 'Alex'
      user.age.must_equal 22
    end

    it 'mass-assignments from stringified hash' do
      user.attributes = { 'name' => 'Alex' }

      user.name.must_equal 'Alex'
      user.age.must_equal 22
    end
  end

  describe '#attributes' do
    it 'returns attributes like hash' do
      user.attributes.must_equal(name: 'Anton', age: 22, last_name: "Affleck", full_name: "Anton Affleck", friends_count: 0, sizes: [], admin: false)
    end

    describe 'when value is nil' do
      it 'returns attributes like hash' do
        user.name  = nil
        user.age   = nil
        user.admin = nil
        user.attributes.must_equal(name: '', age: nil, last_name: "Affleck", full_name: "Anton Affleck", friends_count: 0, sizes: [], admin: false)
      end
    end
  end

  describe '#reset_attribute' do
    it 'reserts attribute value attributes like hash' do
      user.reset_attribute(:name)
      user.name.must_equal 'Ben'
    end
  end

  describe '#==' do
    it 'returns true if objects are equal' do
      user1 = MainUser.new
      user2 = MainUser.new
      user1.must_equal user2
    end

    it 'returns false if objects are not equal' do
      user1 = MainUser.new(name: 'Anton')
      user2 = MainUser.new(name: 'Jon')
      user1.wont_equal user2
    end
  end

  describe '#inspect' do
    it 'returns string with object information' do
      user = SimpleUser.new(name: 'Anton')
      user.inspect.must_equal "#<SimpleUser name=\"Anton\">"
    end
  end

  describe 'setters' do
    let(:user) { MainUser.new(name: 'Anton', age: '22', birthday: 'Thu Nov 29 14:33:20 GMT 2001') }

    it 'converts value to specific type' do
      user.age.must_equal 22
      user.birthday.must_be_instance_of DateTime
      user.birthday.to_s.must_equal '2001-11-29T14:33:20+00:00'
    end
  end
end
