require 'form_obj/mappable/attribute'
require 'form_obj/mappable/array'
require 'form_obj/mappable/model_primary_key'

module FormObj
  module Mappable
    class PrimaryKeyMappingError < RuntimeError; end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def attribute_class
        Mappable::Attribute
      end

      def array_class
        Mappable::Array
      end

      def hash=(value)
        _attributes.each { |attribute| attribute.model_attribute.hash_item = value }
      end

      def model_primary_key
        Mappable::ModelPrimaryKey.new(self._attributes.find(self.primary_key).model_attribute)
      end
    end

    def load_from_model(model)
      load_from_models(default: model)
    end

    def load_from_models(models)
      self.class._attributes.each { |attribute| load_attribute_from_model(attribute, models) }
      self.persisted = true
      self
    end

    def save_to_model(model)
      save_to_models(default: model)
    end

    def save_to_models(models)
      self.class._attributes.each { |attribute | save_attribute_to_model(attribute, models) }
      self.persisted = true
      self
    end

    def primary_key=(val)
      self.class._attributes.find(self.class.primary_key).validate_primary_key!
      super
    end

    private

    def load_attribute_from_model(attribute, models)
      if attribute.subform?
        if attribute.model_attribute.read_from_model?
          self.send(attribute.name).load_from_models(models.merge(default: attribute.model_attribute.read_from_models(models)))
        else
          self.send(attribute.name).load_from_models(models.merge(default: models[attribute.model_attribute.model]))
        end
      elsif attribute.model_attribute.read_from_model?
        self.send("#{attribute.name}=", attribute.model_attribute.read_from_models(models))
      end
    end

    def save_attribute_to_model(attribute, models)
      if attribute.subform?
        if attribute.model_attribute.write_to_model?
          self.send(attribute.name).save_to_models(models.merge(default: attribute.model_attribute.read_from_models(models, create_nested_model_if_nil: true)))
        else
          self.send(attribute.name).save_to_models(models.merge(default: models[attribute.model_attribute.model]))
        end
      elsif attribute.model_attribute.write_to_model?
        attribute.model_attribute.write_to_models(models, self.send(attribute.name))
      end
    end
  end
end