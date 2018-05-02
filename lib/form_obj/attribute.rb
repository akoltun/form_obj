require 'tree_struct'
require 'tree_struct/attribute'

class FormObj < TreeStruct
  class Attribute < ::TreeStruct::Attribute
    def initialize(name, array: false, class: nil, default: nil, parent:, primary_key: nil, &block)
      super(name, array: array, class: binding.local_variable_get(:class), default: default, parent: parent, &block)

      @nested_class.instance_variable_set(:@model_name, ActiveModel::Name.new(@nested_class, nil, name.to_s)) if !@nested_class && block_given?

      if primary_key
        if @nested_class
          @nested_class.primary_key = primary_key
        else
          parent.primary_key = name.to_sym
        end
      end
    end
  end
end
