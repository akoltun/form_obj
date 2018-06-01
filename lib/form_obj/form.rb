require 'form_obj/struct'
require 'form_obj/form/attributes'
require 'form_obj/form/attribute'
require 'form_obj/form/array'
require 'active_model'

module FormObj
  class UnknownAttributeError < RuntimeError; end

  class Form < FormObj::Struct
    extend ::ActiveModel::Naming
    extend ::ActiveModel::Translation

    include ::ActiveModel::Conversion
    include ::ActiveModel::Validations

    private
    self._attributes = Attributes.new

    public

    def self.array_class
      Array
    end

    def self.nested_class
      FormObj::Struct
    end

    def self.attribute_class
      Attribute
    end

    attr_accessor :persisted
    attr_reader :errors

    class_attribute :primary_key, instance_predicate: false, instance_reader: false, instance_writer: false
    self.primary_key = :id

    def self.nested_class
      ::FormObj::Form
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
        attr = self.class._attributes.find(new_attr)
        if attr.nil?
          raise UnknownAttributeError.new(new_attr) if raise_if_not_found
        else
          if attr.subform?
            self.send(new_attr).update_attributes(new_val)
          else
            self.send("#{new_attr}=", new_val)
          end
        end
      end

      self
    end

    def saved
      @persisted = true
      self
    end
  end
end