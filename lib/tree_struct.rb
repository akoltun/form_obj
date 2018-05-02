require 'active_support/core_ext/class/attribute'
require "tree_struct/array"
require "tree_struct/attribute"
require "tree_struct/attributes"

class TreeStruct
  private

  class_attribute :_attributes, instance_predicate: false, instance_reader: false, instance_writer: false
  self._attributes = Attributes.new

  def self._define_attribute_getter(attribute)
    define_method attribute.name do
      _get_attribute_value(attribute)
    end
  end

  def self._define_attribute_setter(attribute)
    define_method "#{attribute.name}=" do |value|
      _set_attribute_value(attribute, value)
    end
  end

  public

  def self.array_class
    Array
  end

  def self.nested_class
    ::TreeStruct
  end

  def self.attribute_class
    Attribute
  end

  def self.attribute(name, opts = {}, &block)
    attr = self.attribute_class.new(name, opts.merge(parent: self), &block)
    self._attributes = self._attributes.add(attr)
    self._define_attribute_getter(attr)
    self._define_attribute_setter(attr)
    self
  end

  def self.attributes
    self._attributes.map(&:name)
  end

  def to_hash
    Hash[self.class._attributes.map { |attribute| [attribute.name, attribute.subform? ? send(attribute.name).to_hash : send(attribute.name)] }]
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