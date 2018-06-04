module FormObj
  class Form < FormObj::Struct
    class Attribute < FormObj::Struct::Attribute
      def initialize(name, array: false, class: nil, default: nil, parent:, primary_key: nil, &block)
        super(name, array: array, class: binding.local_variable_get(:class), default: default, parent: parent, primary_key: primary_key, &block)

        @nested_class.instance_variable_set(:@model_name, ActiveModel::Name.new(@nested_class, nil, name.to_s)) if !@nested_class && block_given?
      end
    end
  end
end
