require "form_obj/version"
require 'form_obj/attribute'
require 'form_obj/array'
require 'tree_struct'
require 'result_obj'
require 'active_model'

class FormObj < TreeStruct
  class UnknownAttributeError < RuntimeError; end

  extend ::ActiveModel::Naming
  extend ::ActiveModel::Translation

  include ::ActiveModel::Conversion
  include ::ActiveModel::Validations

  attr_accessor :persisted
  attr_reader :errors

  class_attribute :primary_key, instance_predicate: false, instance_reader: false, instance_writer: false
  self.primary_key = :id

  def self.nested_class
    ::FormObj
  end

  def self.model_name
    @model_name || super
  end

  def initialize()
    @errors = ActiveModel::Errors.new(self)
    @persisted = false
  end

  def persisted?
    @persisted
  end

  def _set_attribute_value(attribute, value)
    @persisted = false
    super
  end

  def primary_key
    send(self.class.primary_key)
  end

  def primary_key=(val)
    send("#{self.class.primary_key}=", val)
  end

  def update_attributes(new_attrs, raise_if_not_found: true)
    new_attrs.each_pair do |new_attr, new_val|
      attr = self.class.attributes.find { |attr| attr.name == new_attr.to_s }
      if attr.nil?
        raise UnknownAttributeError.new(new_attr) if raise_if_not_found
      else
        if attr.subform
          self.send(new_attr).update_attributes(new_val)
        else
          self.send("#{new_attr}=", new_val)
        end
      end
    end

    self
  end
end
