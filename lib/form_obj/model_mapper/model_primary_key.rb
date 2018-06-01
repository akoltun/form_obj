module FormObj
  module ModelMapper
    class ModelPrimaryKey
      def initialize(model_attribute)
        @model_attribute = model_attribute
      end

      def name
        @model_attribute.last_name
      end

      def read_from_model(model)
        @model_attribute.read_from_model(model, create_nested_model_if_nil: false)
      end
    end
  end
end
