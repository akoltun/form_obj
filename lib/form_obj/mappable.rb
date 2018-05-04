require 'form_obj/mappable/attribute'
require 'form_obj/mappable/array'

module FormObj
  module Mappable
    class PrimaryKeyMappedToNestedModelError < RuntimeError; end

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
        _attributes.each { |attribute| attribute.hash = value }
      end

      def model_primary_key
        primary_key_attributes = self._attributes.find(self.primary_key).model_attributes
        raise PrimaryKeyMappedToNestedModelError.new('Primary key could not be mapped to nested model') if primary_key_attributes.size > 1
        primary_key_attributes.first
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

    private

    def load_attribute_from_model(attribute, models)
      if attribute.subform?
        if attribute.read_from_model?
          self.send(attribute.name).load_from_models(models.merge(default: attribute.read_from_model(models[attribute.model])))
        else
          self.send(attribute.name).load_from_models(models.merge(default: models[attribute.model]))
        end
      elsif attribute.read_from_model?
        self.send("#{attribute.name}=", attribute.read_from_model(models[attribute.model]))
      end
    end
  end
end