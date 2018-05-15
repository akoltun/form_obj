require 'form_obj/mappable/model_attribute'

module FormObj
  module Mappable
    class Attribute < FormObj::Attribute
      attr_reader :model_attribute

      def initialize(name, array: false, class: nil, default: nil, hash: false, model: :default, model_attribute: nil, model_class: nil, parent:, primary_key: nil, &block)
        @hash = hash
        @model_attribute = ModelAttribute.new(model: model, names: model_attribute, classes: model_class, default_name: name, array: array, hash: hash, subform: binding.local_variable_get(:class) || block_given?)

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

      def array?
        @array
      end

      private

      def create_array
        @parent.array_class.new(@nested_class, model_attribute: @model_attribute)
      end
    end
  end
end
