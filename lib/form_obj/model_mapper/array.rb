module FormObj
  module ModelMapper
    class Array < FormObj::Form::Array
      def initialize(item_class, model_attribute:)
        @model_attribute = model_attribute
        super(item_class)
      end

      def load_from_models(models)
        clear
        (models[:default] || []).each do |model|
          create.load_from_models(models.merge(default: model))
        end
        self
      end

      def save_to_models(models)
        model_array = models[:default]
        ids_exists = []
        items_to_add = []

        self.each do |item|
          if model = find_model(model_array, id = item.primary_key)
            item.save_to_models(models.merge(default: model))
            ids_exists << id
          else
            items_to_add << item
          end
        end

        ids_to_remove = model_array.map { |m| model_primary_key.read_from_model(m) } - ids_exists
        delete_models(model_array, ids_to_remove)

        items_to_add.each do |item|
          model_array << model = @model_attribute.create_model # || model_array.create_model
          item.save_to_models(models.merge(default: model))
        end
      end

      def find_model(model_array, id)
        if model_array.respond_to?("find_by_#{model_primary_key.name}")
          model_array.send("find_by_#{model_primary_key.name}", id)
        else
          model_array.find { |m| model_primary_key.read_from_model(m) == id }
        end
      end

      def delete_models(model_array, ids_to_delete)
        if model_array.respond_to?(:destroy_all)
          model_array.destroy_all(model_primary_key.name => ids_to_delete)
        else
          model_array.delete_if { |m| ids_to_delete.include?(model_primary_key.read_from_model(m)) }
        end
      end

      def model_primary_key
        self.item_class.model_primary_key
      end

      def to_models_hash(models)
        self.each { |item| models[:default] << item.to_models_hash(models.merge(default: {}))[:default] }
        models
      end
    end
  end
end
