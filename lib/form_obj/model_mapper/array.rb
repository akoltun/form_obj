module FormObj
  module ModelMapper
    class Array < FormObj::Form::Array
      def initialize(item_class, model_attribute, *args)
        @model_attribute = model_attribute
        super(item_class, *args)
      end

      def load_from_models(models, *args)
        clear
        iterate_through_models_to_load_them(models[:default] || [], *args) do |model|
          build.load_from_models(models.merge(default: model), *args)
        end
        self
      end

      def sync_to_models(models)
        items = define_models_for_CUD(models)

        sync_destruction_to_models(models, items[:destroy])
        sync_update_to_models(models, items[:update])
        sync_creation_to_models(models, items[:create])
      end

      def model_primary_key
        self.item_class.model_primary_key
      end

      def to_models_hash(models)
        self.each { |item| models[:default] << item.to_models_hash(models.merge(default: {}))[:default] }
        models
      end

      private

      attr_reader :model_attribute

      def iterate_through_models_to_load_them(models, *args, &block)
        models.each { |model| block.call(model) }
      end

      def find_model(model_array, id)
        if model_array.respond_to?("find_by_#{model_primary_key.name}")
          model_array.send("find_by_#{model_primary_key.name}", id)
        else
          model_array.find { |m| model_primary_key.read_from_model(m) == id }
        end
      end

      # Should return hash with 3 keys: :create, :update, :destroy
      # In default implementation:
      # :create - array of form objects to be added
      # :update - hash where key is a model to be updated and value is a form object
      # :destroy - array of models to be marked for deletion
      def define_models_for_CUD(models)
        to_be_created = []
        to_be_updated = {}
        to_be_destroyed = select(&:marked_for_destruction?).map(&:primary_key)

        reject(&:marked_for_destruction?).each do |form_object|
          if model = find_model(models[:default], form_object.primary_key)
            to_be_updated[model] = form_object
          else
            to_be_created << form_object
          end
        end

        { create: to_be_created, update: to_be_updated, destroy: to_be_destroyed }
      end

      def sync_destruction_to_models(models, ids_to_destroy)
        if models[:default].respond_to? :where
          models[:default].where(model_primary_key.name => ids_to_destroy).each(&:mark_for_destruction)
        else
          models[:default].delete_if { |model| ids_to_destroy.include? model_primary_key.read_from_model(model) }
        end
      end

      def sync_update_to_models(models, items_to_update)
        items_to_update.each_pair do |model, form_object|
          form_object.sync_to_models(models.merge(default: model))
        end
      end

      def sync_creation_to_models(models, form_objects_to_create)
        form_objects_to_create.each do |form_object|
          models[:default] << model = model_attribute.create_model
          form_object.sync_to_models(models.merge(default: model))
        end
      end
    end
  end
end
