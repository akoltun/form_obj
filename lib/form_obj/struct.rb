require "form_obj/struct/array"
require "form_obj/struct/attribute"
require "form_obj/struct/attributes"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/hash/indifferent_access"

module FormObj
  class UnknownAttributeError < RuntimeError; end
  class WrongDefaultValueClassError < RuntimeError; end
  class NonexistentPrimaryKeyError < NameError; end

  class Struct
    class_attribute :_attributes, instance_predicate: false, instance_reader: false, instance_writer: false
    class_attribute :primary_key, instance_predicate: false, instance_reader: false, instance_writer: false

    self._attributes = Attributes.new
    self.primary_key = :id

    class << self
      def array_class
        Array
      end

      def nested_class
        ::FormObj::Struct
      end

      def attribute_class
        Attribute
      end

      def attribute(name, opts = {}, &block)
        attr = attribute_class.new(name, opts.merge(parent: self), &block)
        self._attributes = _attributes.add(attr)
        _define_attribute_getter(attr)
        _define_attribute_setter(attr)
        self
      end

      def attributes
        _attributes.map(&:name)
      end

      def inspect
        "#{name}#{attributes.size > 0 ? "(#{attributes.join(', ')})" : ''}"
      end

      private

      def _define_attribute_getter(attribute)
        define_method attribute.name do
          _get_attribute_value(attribute)
        end
      end

      def _define_attribute_setter(attribute)
        define_method "#{attribute.name}=" do |value|
          _set_attribute_value(attribute, value)
        end
      end
    end

    def initialize(*args)
      super()
      update_attributes(*args) if args.size > 0 && args[0]
    end

    def primary_key
      send(self.class.primary_key)
    end

    def primary_key=(val)
      send("#{self.class.primary_key}=", val)
    end

    def update_attributes(attrs, raise_if_not_found: true)
      attrs = HashWithIndifferentAccess.new(attrs) unless attrs.is_a? HashWithIndifferentAccess
      attrs.each_pair do |attr_name, attr_value|
        attr = self.class._attributes.find(attr_name)
        if attr.nil?
          raise UnknownAttributeError.new(attr_name) if raise_if_not_found
        else
          if attr.subform? && !attr_value.is_a?(FormObj::Struct)
            read_attribute(attr).update_attributes(attr_value, raise_if_not_found: raise_if_not_found)
          else
            update_attribute(attr, attr_value)
          end
        end
      end

      self
    end

    def to_hash
      Hash[self.class._attributes.map { |attribute| [attribute.name, attribute.subform? ? read_attribute(attribute).to_hash : read_attribute(attribute)] }]
    end

    def inspect
      "#<#{inner_inspect}>"
    end

    private

    def inner_inspect
      attributes = self.class._attributes.map { |attribute| "#{attribute.name}: #{read_attribute(attribute).inspect}"}.join(', ')
      "#{self.class.name}#{attributes.size > 0 ? " #{attributes}" : ''}"
    end

    def update_attribute(attribute, new_value)
      write_attribute(attribute, new_value)
    end

    def read_attribute(attribute)
      send(attribute.name)
    end

    def write_attribute(attribute, value)
      send("#{attribute.name}=", value)
    end

    def _get_attribute_value(attribute)
      value = instance_variable_get("@#{attribute.name}")
      value = instance_variable_set("@#{attribute.name}", attribute.default_value) if value.nil?
      value
    end

    def _set_attribute_value(attribute, value)
      attribute.validate_value!(value)
      instance_variable_set("@#{attribute.name}", value)
    end
  end
end