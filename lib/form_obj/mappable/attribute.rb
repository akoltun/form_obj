require 'form_obj/mappable/model_attribute'

module FormObj
  module Mappable
    class Attribute < FormObj::Attribute
      attr_reader :model, :model_class

      def initialize(name, array: false, class: nil, default: nil, hash: false, model: :default, model_attribute: nil, model_class: nil, parent:, primary_key: nil, &block)
        @model = model
        @model_class = model_class.is_a?(::Enumerable) ? model_class : [model_class || (hash ? ::Hash : name.to_s.camelize)]
        @model_attribute = ModelAttribute.new(model_attribute, name)

        if block_given?
          new_block = Proc.new do
            include FormObj::Mappable
            class_eval &block
          end
        end
        super(name, array: array, class: binding.local_variable_get(:class), default: default, parent: parent, primary_key: primary_key, &new_block)

        @nested_class = Class.new(@nested_class) if binding.local_variable_get(:class)
        @nested_class.hash = hash if @nested_class
      end

      def hash=(value)
        @model_attribute.hash = value
      end

      def read_from_model?
        @model_attribute.present?
      end

      def read_from_model(model)
        @model_attribute.read_from_model(model)
      end
    end
  end
end
