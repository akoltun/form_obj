require "form_obj/version"
require 'form_obj/attribute'
require 'form_obj/array'
require 'result_obj'
require 'active_model'

class FormObj
  class UnknownAttributeError < RuntimeError; end
  class WrongHashAttributeValue < RuntimeError; end
  class WrongArrayAttributeValue < RuntimeError; end

  extend ::ActiveModel::Naming
  extend ::ActiveModel::Translation

  include ::ActiveModel::Conversion
  include ::ActiveModel::Validations

  private

  class_attribute :_attributes, instance_predicate: false, instance_reader: false, instance_writer: false
  self._attributes = []

  public

  attr_accessor :persisted
  attr_reader :errors

  class_attribute :primary_key, instance_predicate: false, instance_reader: false, instance_writer: false
  self.primary_key = :id

  def self.model_name
    @model_name || super
  end

  def self.model_primary_key
    primary_key_attributes = self._attributes.find { |attr| attr.name == self.primary_key.to_s }.model_attributes
    raise 'Primary key could not be mapped to nested model' if primary_key_attributes.size > 1
    primary_key_attributes.first
  end

  def self.attribute(name, opts = {}, &block)
    primary_key = opts.delete(:primary_key)
    hash = opts[:hash]
    klass = opts.delete(:class)
    if !klass && block_given?
      klass = Class.new(FormObj, &block)
      klass.instance_variable_set(:@model_name, ActiveModel::Name.new(klass, nil, name.to_s))
    end
    self._attributes += [attr = Attribute.new(name, klass, opts)]

    if klass
      klass.primary_key = primary_key if primary_key

      if opts[:array]
        define_method name do
          instance_variable_get("@#{name}") || instance_variable_set("@#{name}", FormObj::Array.new(klass, hash: hash, model_class: attr.model_class.last))
        end
        define_method "#{name}=" do |val|
          unless val.class == FormObj::Array
            raise ArgumentError.new(":#{name} attribute value should be of class #{self.class.name}::Array while attempt to assign value of class #{val.class.name}")
          end
          unless val.item_class == klass
            raise ArgumentError.new(":#{name} attribute value should be a form array with items of class #{klass.name} attempt to assign a form array with items of class #{val.item_class.name}")
          end

          @persisted = false
          instance_variable_set("@#{name}", val)
        end

      else
        define_method name do
          instance_variable_get("@#{name}") || instance_variable_set("@#{name}", klass.new({}, hash: hash))
        end
        define_method "#{name}=" do |val|
          unless val.class == klass
            raise ArgumentError.new(":#{name} attribute value should be of class #{klass.name} while attempt to assign value of class #{val.class.name}")
          end

          @persisted = false
          instance_variable_set("@#{name}", val)
        end
      end

    else
      attr_reader name
      define_method "#{name}=" do |val|
        @persisted = false
        instance_variable_set("@#{name}", val)
      end
      self.primary_key = name.to_sym if primary_key
    end
  end

  def initialize(models = {}, opts = { hash: false })
    @errors = ActiveModel::Errors.new(self)
    @persisted = false
    @hash = opts[:hash]
    load_from_models(models) if models.present?
  end

  def persisted?
    @persisted
  end

  def primary_key
    send(self.class.primary_key)
  end

  def primary_key=(val)
    send("#{self.class.primary_key}=", val)
  end

  def load_from_models(models)
    attributes.each { |attribute| load_attribute_from_model(attribute, models) }
    @persisted = true
    self
  end

  def save_to_models(models)
    attributes.each { |attribute | save_attribute_to_model(attribute, models) }
    @persisted = true
    self
  end

  def load_from_model(model)
    load_from_models(default: model)
  end

  def save_to_model(model)
    save_to_models(default: model)
  end

  def update_attributes(new_attrs, raise_if_not_found: true)
    @persisted = false
    new_attrs.each_pair do |new_attr, new_val|
      attr = attributes.find { |attr| attr.name == new_attr.to_s }
      if attr.nil?
        raise UnknownAttributeError.new(new_attr) if raise_if_not_found
      else
        if attr.subform && attr.array?
          if new_val.is_a?(Enumerable)
            self.send(new_attr).update_attributes(new_val)
          else
            raise WrongArrayAttributeValue.new("#{new_attr}: #{new_val.inspect}")
          end
        elsif attr.subform
          if new_val.is_a? Hash
            self.send(new_attr).update_attributes(new_val)
          else
            raise WrongHashAttributeValue.new("#{new_attr}: #{new_val.inspect}")
          end
        else
          self.send("#{new_attr}=", new_val)
        end
      end
    end
    self
  end

  def to_hash
    Hash[attributes.map { |attribute| [attribute.name.to_sym, attribute.subform ? send(attribute.name).to_hash : send(attribute.name)] }]
  end

  def to_model_hash(model = :default)
    export_to_model_hash(model => (hash = {}))
    hash
  end

  def export_to_model_hash(models)
    attributes.each do |attribute|
      if attribute.array?
        value = []
        if models[attribute.model]
          val = if attribute.model_attributes.present?
                  attribute
                      .model_attributes
                      .map { |ma| ma.to_s[0] == ':' ? ma[1..-1] : ma }
                      .reverse
                      .reduce(value) { |h, k| { k.to_sym => h } }
                else
                  { self: value }
                end
          models[attribute.model].merge!(val)
        end
        nested_models = models.merge(default: value)
        send(attribute.name).export_to_model_hash(nested_models)

      elsif attribute.subform # && !attribute.array?
        value = {}
        if models[attribute.model]
          if attribute.model_attributes.present?
            val = attribute
                      .model_attributes
                      .map { |ma| ma.to_s[0] == ':' ? ma[1..-1] : ma }
                      .reverse
                      .reduce(value) { |h, k| { k.to_sym => h } }
            models[attribute.model].merge!(val)
            nested_models = models.merge(default: value)
          else
            if attribute.model == :default
              nested_models = models
            else
              nested_models = models.merge(default: models[attribute.model])
            end
          end
        else
          nested_models = models.merge(default: value)
        end
        send(attribute.name).export_to_model_hash(nested_models)

      else
        if models[attribute.model]
          if attribute.model_attributes.present?
            value = send(attribute.name)
            val = attribute
                      .model_attributes
                      .map { |ma| ma.to_s[0] == ':' ? ma[1..-1] : ma }
                      .reverse
                      .reduce(value) { |h, k| { k.to_sym => h } }
            models[attribute.model].merge!(val)
          end
        end
      end
    end
    models
  end

  def copy_errors_from_model(model)
    copy_errors_from_models(default: model)
  end

  def copy_errors_from_models(models)
    attributes.each do |attribute|
      if attribute.subform
      else
        @errors[attribute.name].push(*read_attribute_errors_from_model(attribute, models[attribute.model]))
      end
    end
    self
  end

  private

  def attributes
    self.class._attributes.clone
  end

  def load_attribute_from_model(attribute, models)
    if attribute.subform
      if attribute.array?
        self.send(attribute.name).clear
        if (model_array = if attribute.model_attributes.present?
                            read_attribute_from_model(attribute, models[attribute.model])
                          else
                            models[attribute.model]
                          end)
          model_array.each do |model|
            self.send(attribute.name).create.load_from_models(models.merge(default: model))
          end
        end
      else
        if attribute.model_attributes.present?
          self.send(attribute.name).load_from_models(models.merge(default: read_attribute_from_model(attribute, models[attribute.model])))
        else
          self.send(attribute.name).load_from_models(models.merge(default: models[attribute.model]))
        end
      end
    else
      if attribute.model_attributes.present?
        self.send("#{attribute.name}=", read_attribute_from_model(attribute, models[attribute.model]))
      end
    end
  end

  def read_attribute_from_model(attribute, model, create_nested_form_if_nil: false)
    m = attribute
            .model_attributes[1..-1]
            .reduce(
                {
                    index: 0,
                    model: _read_attribute(
                        model: model,
                        model_attr: attribute.model_attributes.first,
                        hash: @hash,
                        nested_form_class: create_nested_form_if_nil ? ((attribute.model_class.size == 1 && attribute.array?) ? ::Array : attribute.model_class.first) : nil
                    )
                }
            ) { |a, m_attr|
              {
                  index: a[:index] + 1,
                  model: _read_attribute(
                      model: a[:model],
                      model_attr: m_attr,
                      nested_form_class: create_nested_form_if_nil ? ((attribute.model_class.size == a[:index] + 2 && attribute.array?) ? ::Array : attribute.model_class[a[:index] + 1]) : nil
                  )
              }
            }[:model]
  end

  def _read_attribute(model_attr:, model:, hash: false, nested_form_class: nil)
    return nil if model.nil?

    result = if hash
               model[model_attr.to_sym].nil? ? model[model_attr.to_s] : model[model_attr.to_sym]
             elsif model_attr.to_s[0] == ':'
               model[model_attr[1..-1].to_sym].nil? ? model[model_attr[1..-1].to_s] : model[model_attr[1..-1].to_sym]
             else
               model.send(model_attr)
             end

    if result.nil? && nested_form_class
      result = (nested_form_class.is_a?(String) ? nested_form_class.constantize : nested_form_class).try(:new)
      if hash
        model[model_attr.to_sym] = result
      elsif model_attr.to_s[0] == ':'
        model[model_attr[1..-1].to_sym] = result
      else
        model.send("#{model_attr}=", result)
      end
    end

    result
  end

  def read_attribute_errors_from_model(attribute, model)
    m = if attribute.model_attributes.size > 1
          attribute
              .model_attributes[1..-2]
              .reduce(
                  {
                      index: 0,
                      model: _read_attribute(
                          model: model,
                          model_attr: attribute.model_attributes.first,
                          hash: @hash,
                          )
                  }
              ) { |a, m_attr|
                {
                    index: a[:index] + 1,
                    model: _read_attribute(
                        model: a[:model],
                        model_attr: m_attr,
                        )
                }
              }[:model]

        elsif attribute.model_attributes.size == 1
          model
        else
          nil
        end

    if m.nil?
      []
    else
      _read_attribute_error(model_attr: attribute.model_attributes.last, model: m, hash: (attribute.model_attributes.size == 1) && @hash)
    end
  end

  def _read_attribute_error(model_attr:, model:, hash: false)
    if hash || model_attr.to_s[0] == ':'
      []
    else
      model.errors[model_attr.to_sym]
    end
  end

  def save_attribute_to_model(attribute, models)
    if attribute.subform
      if attribute.array?
        if attribute.model_attributes.present?
          self.send(attribute.name).save_to_models(models.merge(default: read_attribute_from_model(attribute, models[attribute.model], create_nested_form_if_nil: true)))
        else
          self.send(attribute.name).save_to_models(models.merge(default: models[attribute.model]))
        end
      else
        if attribute.model_attributes.present?
          self.send(attribute.name).save_to_models(models.merge(default: read_attribute_from_model(attribute, models[attribute.model], create_nested_form_if_nil: true)))
        else
          self.send(attribute.name).save_to_models(models.merge(default: models[attribute.model]))
        end
      end
    else
      if attribute.model_attributes.present?
        write_attribute_to_model(attribute, models[attribute.model], self.send(attribute.name))
      end
    end
  end

  def write_attribute_to_model(attribute, model, value)
    path = attribute.model_attributes[0..-2]
    model_attr = attribute.model_attributes.last

    if path.present?
      _write_attribute(
          model: path[1..-1]
                     .reduce({
                                 index: 0,
                                 model: _read_attribute(
                                     model: model,
                                     model_attr: attribute.model_attributes.first,
                                     hash: @hash,
                                     nested_form_class: attribute.model_class.first
                                 )
                             }) { |a, m_attr|
                       {
                           index: a[:index] + 1,
                           model: _read_attribute(
                               model: a[:model],
                               model_attr: m_attr,
                               nested_form_class: attribute.model_class[a[:index] + 1]
                           )
                       }
                     }[:model],
          model_attr: model_attr,
          value: value
      )
    else
      _write_attribute(model: model, model_attr: model_attr, hash: @hash, value: value)
    end
  end

  def _write_attribute(model_attr:, model:, hash: false, value:)
    if hash
      model[(model.key?(model_attr.to_s) && !model.key?(model_attr.to_sym)) ? model_attr.to_s : model_attr.to_sym] = value
    elsif model_attr.to_s[0] == ':'
      model[(model.key?(model_attr[1..-1].to_s) && !model.key?(model_attr[1..-1].to_sym)) ? model_attr[1..-1].to_s : model_attr[1..-1].to_sym] = value
    else
      model.send("#{model_attr}=", value)
    end
  end
end
