require "form_obj/struct/array"
require "form_obj/struct/attribute"
require "form_obj/struct/attributes"
require "active_support/core_ext/class/attribute"

module FormObj
  class UnknownAttributeError < RuntimeError; end
  class WrongDefaultValueClass < RuntimeError; end

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
        self._attributes.map(&:name)
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
      update_attributes(*args) if args.size > 0
    end

    def primary_key
      send(self.class.primary_key)
    end

    def primary_key=(val)
      send("#{self.class.primary_key}=", val)
    end

    def update_attributes(new_attrs, raise_if_not_found: true)
      new_attrs.each_pair do |new_attr, new_val|
        attr = self.class._attributes.find(new_attr)
        if attr.nil?
          raise UnknownAttributeError.new(new_attr) if raise_if_not_found
        else
          if attr.subform?
            self.send(new_attr).update_attributes(new_val, raise_if_not_found: raise_if_not_found)
          else
            self.send("#{new_attr}=", new_val)
          end
        end
      end

      self
    end

    def to_hash
      Hash[self.class._attributes.map { |attribute| [attribute.name, attribute.subform? ? send(attribute.name).to_hash : send(attribute.name)] }]
    end

    def inspect
      "#<#{self.class.name} #{self.class._attributes.map { |attribute| "#{attribute.name}: #{send(attribute.name).inspect}"}.join(', ')}>"
    end

    private

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