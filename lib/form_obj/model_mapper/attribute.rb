require 'form_obj/model_mapper/model_attribute'

module FormObj
  module ModelMapper
    class Attribute < FormObj::Form::Attribute
      attr_reader :model_attribute

      def initialize(name, array: false, class: nil, default: nil, model_hash: false, model: :default, model_attribute: nil, model_class: nil, model_nesting: true, parent:, primary_key: nil, read_from_model: true, write_to_model: true, &block)
        @model_attribute = ModelAttribute.new(
            array: array,
            classes: model_class,
            default_name: name,
            hash: model_hash,
            model: model,
            names: model_attribute,
            nesting: model_nesting,
            read_from_model: read_from_model,
            subform: binding.local_variable_get(:class) || block_given?,
            write_to_model: write_to_model,
        )

        if block_given?
          new_block = Proc.new do
            include FormObj::ModelMapper
            class_eval &block
          end
        end
        super(name, array: array, class: binding.local_variable_get(:class), default: default, parent: parent, primary_key: primary_key, &new_block)

        @nested_class.model_hash = model_hash if @nested_class
      end

      def array?
        @array
      end

      private

      def create_array(*args)
        @parent.array_class.new(@nested_class, @model_attribute, *args)
      end
    end
  end
end
