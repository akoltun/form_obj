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

    attr_accessor :persisted
    attr_reader :errors

    def initialize(*args)
      @errors = ActiveModel::Errors.new(self)
      @persisted = false
      super
    end

    def persisted?
      @persisted
    end

    def _set_attribute_value(attribute, value)
      @persisted = false unless _get_attribute_value(attribute) === value
      super
    end

    def saved
      @persisted = true
      self
    end
  end
end