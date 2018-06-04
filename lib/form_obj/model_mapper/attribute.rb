require 'form_obj/model_mapper/model_attribute'

module FormObj
  module ModelMapper
    class Attribute < FormObj::Form::Attribute
      attr_reader :model_attribute

      def initialize(name, array: false, class: nil, default: nil, model_hash: false, model: :default, model_attribute: nil, model_class: nil, model_nesting: true, parent:, primary_key: nil, &block)
        @model_attribute = ModelAttribute.new(model: model, names: model_attribute, classes: model_class, default_name: name, nesting: model_nesting, array: array, hash: model_hash, subform: binding.local_variable_get(:class) || block_given?)

        if block_given?
          new_block = Proc.new do
            include FormObj::ModelMapper
            class_eval &block
          end
        end
        super(name, array: array, class: binding.local_variable_get(:class), default: default, parent: parent, primary_key: primary_key, &new_block)

        @nested_class            = Class.new(@nested_class) if binding.local_variable_get(:class)
        @nested_class.model_hash = model_hash if @nested_class
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
