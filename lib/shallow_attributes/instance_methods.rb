module ShallowAttributes
  # Abstract class for value classes. Provides some helper methods for
  # working with attributes.
  #
  # @abstract
  #
  # @since 0.1.0
  module InstanceMethods
    # Lambda object for getting attributes hash for a specific
    # value object.
    #
    # @private
    #
    # @since 0.1.0
    TO_H_PROC = ->(value) { value.respond_to?(:to_hash) ? value.to_hash : value }

    # Initialize an instance object with specific attributes
    #
    # @param [Hash] attrs the attributes contained in the class
    #
    # @example Create new User instance
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String
    #   end
    #
    #   User.new(name: 'Anton') # => #<User @attributes={:name=>"Anton"}, @name="Anton">
    #
    # @return the new instance of value class with specific attributes
    #
    # @since 0.1.0
    def initialize(attrs = {})
      @attributes = {}
      attrs.each_pair do |key, value|
        key = key.to_sym
        @attributes[key] = value if default_values.key?(key)
      end
      define_attributes
      define_default_attributes
      define_mandatory_attributes
    end

    # Returns hash of object attributes
    #
    # @example Returns all user attributes
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String
    #   end
    #
    #   user = User.new(name: 'Anton')
    #   user.attributes # => { name: "Anton" }
    #
    # @return [Hash]
    #
    # @since 0.1.0
    def attributes
      hash = {}
      @attributes.map do |key, value|
        hash[key] =
          value.is_a?(Array) ? value.map(&TO_H_PROC) : TO_H_PROC.call(value)
      end
      hash
    end

    # @since 0.1.0
    alias_method :to_h, :attributes

    # @since 0.1.0
    alias_method :to_hash, :attributes

    # Attribute values mass-assignment
    #
    # @param [Hash] attributes the attributes which will be assignment
    #
    # @example Assignment new user name
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String
    #   end
    #
    #   user = User.new(name: 'Anton')
    #   user.attributes = { name: "Ben" }
    #   user.attributes # => { name: "Ben" }
    #
    # @return [Hash] attributes hash
    #
    # @since 0.1.0
    def attributes=(attributes)
      attributes.each_pair do |key, value|
        @attributes[key.to_sym] = value
      end
      define_attributes
    end

    # Reset specific attribute to default value.
    #
    # @param [Symbol] attribute the attribute which will be reset
    #
    # @example Reset name value
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String, default: 'Ben'
    #   end
    #
    #   user = User.new(name: 'Anton')
    #   user.reset_attribute(:name)
    #   user.attributes # => { name: "Ben" }
    #
    # @return the last attribute value
    #
    # @since 0.1.0
    def reset_attribute(attribute)
      instance_variable_set("@#{attribute}", default_value_for(attribute))
    end

    # Sets new values and returns self. Needs for embedded value.
    #
    # @private
    #
    # @param [Hash] value the new attributes for current object
    # @param [Hash] _options
    #
    # @example Use embedded values
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String, default: 'Ben'
    #   end
    #
    #   class Post
    #     include ShallowAttributes
    #     attribute :author, User
    #   end
    #
    #   post = Post.new(author: { name: 'Anton'} )
    #   post.user.name # => 'Anton'
    #
    # @return the object
    #
    # @since 0.1.0
    def coerce(value, _options = {})
      self.attributes =
        if value.class.included_modules.include?(ShallowAttributes)
          value.to_h
        else
          value
        end

      self
    end

    # Compare values of two objects
    #
    # @param [Object] object the other object
    #
    # @example Compare two value objects
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String, default: 'Ben'
    #   end
    #
    #   user1 = User.new(name: 'Anton')
    #   user2 = User.new(name: 'Anton')
    #   user1 == user2 # => true
    #
    # @return [boolean]
    #
    # @since 0.1.0
    def ==(object)
      self.to_h == object.to_h
    end

    # Inspect instance object
    #
    # @example Inspect the object
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String, default: 'Ben'
    #   end
    #
    #   user = User.new(name: 'Anton')
    #   user.inspect # => "#<User name=\"Anton\">"
    #
    # @return [String]
    #
    # @since 0.1.0
    def inspect
      "#<#{self.class}#{attributes.map{ |k, v| " #{k}=#{v.inspect}" }.join}>"
    end

    private

    # Define default values for attributes.
    #
    # @private
    #
    # @return the object
    #
    # @since 0.1.0
    def define_default_attributes
      default_values.each do |key, value|
        next unless @attributes[key].nil? && !value.nil?
        send("#{key}=", default_value_for(key))
      end
    end

    # Define mandatory attributes for object and raise exception
    # if they were not provided
    #
    # @private
    #
    # @raise [MissingAttributeError] if attribute was not provided
    #
    # @return the object
    #
    # @since 0.10.0
    def define_mandatory_attributes
      mandatory_attributes.each do |key, value|
        next unless @attributes[key].nil? && value
        raise ShallowAttributes::MissingAttributeError, %(Mandatory attribute "#{key}" was not provided)
      end
    end

    # Define attributes from `@attributes` instance value.
    #
    # @private
    #
    # @return the object
    #
    # @since 0.1.0
    def define_attributes
      @attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    # Returns default value for specific attribute. Default values hash
    # is taken from class getter `default_values`.
    #
    # @private
    #
    # @return [nil] if default value not defined
    # @return [Object] if default value is defined
    #
    # @since 0.1.0
    def default_value_for(attribute)
      value = default_values[attribute]

      case value
      when Proc
        value.call(self, attribute)
      when Symbol, String
        respond_to?(value, true) ? send(value) : value
      else
        value
      end
    end

    # Returns hash of default class values
    #
    # @private
    #
    # @return [Hash]
    #
    # @since 0.1.0
    def default_values
      @default_values ||= self.class.default_values
    end

    # Returns hash of mandatory class attributes
    #
    # @private
    #
    # @return [Hash]
    #
    # @since 0.10.0
    def mandatory_attributes
      @mandatory_attributes ||= self.class.mandatory_attributes
    end
  end
end
