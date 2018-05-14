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

    # def to_models_hash(hash = {})
    #   self.class._attributes.each { |attribute| attribute_to_models_hash(attribute: attribute, models_hash: hash) }
    #   hash
    # end
    #
    # def to_model_hash(model = :default)
    #   to_models_hash[model]
    # end

    def to_model_hash(model = :default)
      export_to_model_hash(model => (hash = {}))
      hash
    end

    def export_to_model_hash(models)
      self.class._attributes.each do |attribute|
        if attribute.subform?
          nested_models = if attribute.array?
                            value = []
                            if models[attribute.model_attribute.model]
                              val = if attribute.model_attribute.write_to_model?
                                      attribute.model_attribute.to_model_hash(value)
                                    else
                                      { self: value }
                                    end
                              models[attribute.model_attribute.model].merge!(val)
                            end
                            models.merge(default: value)

                          else
                            value = {}
                            if models[attribute.model_attribute.model]
                              if attribute.model_attribute.write_to_model?
                                val = attribute.model_attribute.to_model_hash(value)
                                models[attribute.model_attribute.model].merge!(val)
                                models.merge(default: value)
                              else
                                if attribute.model_attribute.model == :default
                                  models
                                else
                                  models.merge(default: models[attribute.model_attribute.model])
                                end
                              end
                            else
                              models.merge(default: value)
                            end

                          end

          send(attribute.name).export_to_model_hash(nested_models)

        elsif models[attribute.model_attribute.model] && attribute.model_attribute.write_to_model?
          value = send(attribute.name)
          val = attribute.model_attribute.to_model_hash(value)
          models[attribute.model_attribute.model].merge!(val)
        end
      end
      models
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

    # def attribute_to_models_hash(attribute:, models_hash:)
    #   value = self.send(attribute.name)
    #
    #   if attribute.subform?
    #     value = value.to_models_hash(models_hash.merge(default: models_hash[attribute.model_attribute.model]))[:default]
    #     attribute.model_attribute.to_model_hash(value: value, hash: models_hash)
    #   else
    #     attribute.model_attribute.to_model_hash(value: value, hash: models_hash)
    #   end
    # end
    #
    # # def export_attribute_to_models_hash(attribute:, models_hash:)
    # #   value = self.send(attribute.name)
    # #   value = value.export_attribu
    # #
    # #   if attribute.subform?
    # #     if attribute.model_attribute.write_to_model?
    # #       self.send(attribute.name).export_to_models_hash(models.merge(default: attribute.model_attribute.read_from_models(models, create_nested_model_if_nil: true)))
    # #     else
    # #       self.send(attribute.name).save_to_models(models.merge(default: models[attribute.model_attribute.model]))
    # #     end
    # #   elsif attribute.model_attribute.write_to_model?
    # #     attribute.model_attribute.write_to_models(models, self.send(attribute.name))
    # #   end
    # # end
    # #
    # # def attribute_to_model_hash(attribute:, model:, hash:)
    # #   value = self.send(attribute.name)
    # #   value = value.to_model_hash(model) if attribute.subform?
    # #
    # #   if attribute.model_attribute.write_to_model?
    # #     attribute.model_attribute.to_model_hash(model: model, value: value, hash: hash)
    # #   elsif attribute.subform?
    # #     value = { self: value } if attribute.array?
    # #     hash.merge!(value)
    # #   end
    # # end
  end
end