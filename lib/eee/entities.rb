module EEE

  module Entities

    class Base

      def self.property(prop)
        properties prop
      end

      def self.properties(*props)
        attr_accessor *props
        unless method_defined? :id
          id props.first
        end
      end

      def self.id(*props)
        define_method :id do
          props
            .map { |prop| self.send prop }
            .join ':'
        end
      end

      def self.[](data)
        entity = new
        data.each_pair do |key, value|
          entity.send "#{key}=", value if entity.respond_to? "#{key}="
        end

        entity
      end

    end

    module Attributes

      attr_reader :attrs

      def set_attribute(name, value, is_public = true)
        if name.is_a? Attribute
          attribute = name
        else 
          attribute = Attribute.new name, value, is_public
        end

        @attrs = @attrs.select { |attr| attr.name != attribute.name }
        @attrs << attribute
      end

      def get_attribute(name)
        @attrs.find { |attr| attr.name == name }
      end

      def method_missing(method, *args)
        is_setter = method.to_s.end_with? '='
        name = method.to_s.chomp '='

        if is_setter
          set_attribute name, args.first
        else
          get_attribute name
        end
      end

      module ClassMethods

        def [](data)
          entity = super data

          if data['attrs']
            data['attrs'].each do |attr|
              entity.set_attribute Attribute[attr]
            end
          end

          entity
        end

      end

      def self.included(entity_class)
        entity_class.extend ClassMethods
      end

    end

    class Attribute
      attr_reader :name
      attr_reader :value
      attr_reader :is_public

      def initialize(name, value, is_public)
        @name = name
        @value = value
        @is_public = is_public
      end

      def self.[](data)
        attribute = new data['name'], data['value'], data['is_public']
      end

    end

    class User < Base
      property :username
      include Attributes
    end

    class Group < Base
      property :groupname
      property :title
      include Attributes
    end

    class Calendar < Base
      property :name
      property :owner
      property :perm
      include Attributes
    end

    class Alias < Base
      property :alias
    end

    class UserPermission < Base
      property :perm
      property :user
    end

    class GroupPermission < Base
      property :perm
      property :group
    end

  end

end
