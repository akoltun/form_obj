require 'form_obj/form'
require 'form_obj/model_mapper/attribute'
require 'form_obj/model_mapper/array'
require 'form_obj/model_mapper/model_primary_key'

module FormObj
  module ModelMapper
    class PrimaryKeyMappingError < RuntimeError; end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def attribute_class
        ModelMapper::Attribute
      end

      def array_class
        ModelMapper::Array
      end

      def model_hash=(value)
        _attributes.each { |attribute| attribute.model_attribute.hash_item = value }
      end

      def model_primary_key
        ModelMapper::ModelPrimaryKey.new(_attributes.find(primary_key).model_attribute)
      end

      def load_from_model(*args)
        new.load_from_model(*args)
      end

      def load_from_models(*args)
        new.load_from_models(*args)
      end
    end

    def load_from_model(model, *args)
      load_from_models({ default: model }, *args)
    end

    def load_from_models(models, *args)
      self.class._attributes.each { |attribute| load_attribute_from_model(attribute, models, *args) }
      self.persisted = true
      self
    end

    def sync_to_model(model)
      sync_to_models(default: model)
    end

    def sync_to_models(models)
      self.class._attributes.each { |attribute | sync_attribute_to_model(attribute, models) }
      self.persisted = true
      self
    end

    def primary_key=(val)
      self.class._attributes.find(self.class.primary_key).validate_primary_key!
      super
    end

    def to_model_hash(model = :default)
      to_models_hash[model]
    end

    def to_models_hash(models = {})
      self.class._attributes.each do |attribute|
        attribute_to_models_hash(attribute, models)
      end
      models
    end

    def copy_errors_from_model(model)
      copy_errors_from_models(default: model)
    end

    def copy_errors_from_models(models)
      self.class._attributes.each do |attribute|
        if attribute.subform?
        elsif attribute.model_attribute.write_to_model? # Use :write_to_model? instead of :read_to_model? because validation errors appears after writing to model
          @errors[attribute.name].push(*attribute.model_attribute.read_errors_from_models(models))
        end
      end
      self
    end

    private

    def load_attribute_from_model(attribute, models, *args)
      return unless attribute.model_attribute.read_from_model?

      if attribute.subform?
        if attribute.model_attribute.nesting?
          read_attribute(attribute).load_from_models(models.merge(default: attribute.model_attribute.read_from_models(models)), *args)
        else
          read_attribute(attribute).load_from_models(models.merge(default: models[attribute.model_attribute.model]), *args)
        end
      else
        write_attribute(attribute, attribute.model_attribute.read_from_models(models))
      end
    end

    def sync_attribute_to_model(attribute, models)
      return unless attribute.model_attribute.write_to_model?

      if attribute.subform?
        if attribute.model_attribute.nesting?
          read_attribute(attribute).sync_to_models(models.merge(default: attribute.model_attribute.read_from_models(models, create_nested_model_if_nil: true)))
        else
          read_attribute(attribute).sync_to_models(models.merge(default: models[attribute.model_attribute.model]))
        end
      else
        attribute.model_attribute.write_to_models(models, read_attribute(attribute))
      end
    end

    def attribute_to_models_hash(attribute, models)
      return unless attribute.model_attribute.write_to_model?

      val = if attribute.subform?
              if attribute.array?
                []
              else
                attribute.model_attribute.nesting? ? {} : (models[attribute.model_attribute.model] ||= {})
              end
            else
              read_attribute(attribute)
            end

      value = if attribute.subform? && !attribute.model_attribute.nesting?
                attribute.array? ? { self: val } : {}
              else
                attribute.model_attribute.to_model_hash(val)
              end

      (models[attribute.model_attribute.model] ||= {}).merge!(value)
      read_attribute(attribute).to_models_hash(models.merge(default: val)) if attribute.subform?
    end
  end
end