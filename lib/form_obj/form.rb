require 'form_obj/struct'
require 'form_obj/form/attributes'
require 'form_obj/form/attribute'
require 'form_obj/form/array'
require 'active_model'

module FormObj
  class Form < FormObj::Struct
    extend ::ActiveModel::Naming
    extend ::ActiveModel::Translation

    include ::ActiveModel::Conversion
    include ::ActiveModel::Validations

    self._attributes = Attributes.new

    class << self
      def array_class
        Array
      end

      def nested_class
        ::FormObj::Form
      end

      def attribute_class
        Attribute
      end

      def model_name
        @model_name || super
      end
    end

    attr_writer :persisted
    attr_reader :errors

    def initialize(*args)
      @errors = ActiveModel::Errors.new(self)
      @persisted = false
      super
    end

    def persisted?
      @persisted && self.class._attributes.reduce(true) { |persisted, attr|
        persisted && (!attr.subform? || read_attribute(attr).persisted?)
      }
    end

    def mark_as_persisted
      self.persisted = true
      self.class._attributes.each { |attr|
        read_attribute(attr).mark_as_persisted if attr.subform?
      }
      self
    end

    def mark_for_destruction
      @marked_for_destruction = true
      self.class._attributes.each { |attr|
        read_attribute(attr).mark_for_destruction if attr.subform?
      }
      self.persisted = false
      self
    end

    def marked_for_destruction?
      @marked_for_destruction ||= false
    end

    def update_attributes(attrs, raise_if_not_found: false)
      super
    end

    private

    def _set_attribute_value(attribute, value)
      @persisted = false unless _get_attribute_value(attribute) === value
      super
    end

    def inner_inspect
      "#{super}#{marked_for_destruction? ? ' marked_for_destruction' : ''}"
    end
  end
end