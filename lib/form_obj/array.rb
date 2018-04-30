require 'typed_array'

class FormObj
  class Array < TypedArray
    def initialize(klass, hash: false, model_class: nil)
      @item_hash = hash
      @model_class = model_class
      super(klass)
    end

    def item_hash?
      @item_hash
    end

    def create
      self << (item = item_class.new(hash: @item_hash))
      item
    end

    def update_attributes(vals)
      ids_exists = []
      items_to_add = []

      vals.each do |val|
        id = hash_val(val, item_class.primary_key)
        item = self.find { |i| i.primary_key == id }
        if item
          item.update_attributes(val)
          ids_exists << id
        else
          items_to_add << val
        end
      end

      ids_to_remove = self.map(&:primary_key) - ids_exists
      self.delete_if { |item| ids_to_remove.include? item.primary_key }

      items_to_add.each do |item|
        self.create.update_attributes(item)
      end

      sort! { |a, b| vals.index { |val| hash_val(val, item_class.primary_key) == a.primary_key } <=> vals.index { |val| hash_val(val, item_class.primary_key) == b.primary_key } }
    end

    def save_to_models(models)
      model_primary_key = self.item_class.model_primary_key
      default_models = models[:default]
      ids_exists = []
      items_to_add = []

      self.each do |item|
        id = item.primary_key
        model = if default_models.respond_to?("find_by_#{model_primary_key}")
                  default_models.send("find_by_#{model_primary_key}", id)
                elsif @item_hash
                  default_models.find { |m| (m.key?(model_primary_key.to_sym) ? m[model_primary_key.to_sym] : m[model_primary_key.to_s]) == id }
                else
                  default_models.find { |m| m.send(model_primary_key) == id }
                end
        if model
          item.save_to_models(models.merge(default: model))
          ids_exists << id
        else
          items_to_add << item
        end
      end

      ids_to_remove = if @item_hash
                        default_models.map { |m| m.key?(model_primary_key.to_sym) ? m[model_primary_key.to_sym] : m[model_primary_key.to_s] }
                      else
                        default_models.map(&(model_primary_key.to_sym))
                      end - ids_exists
      if default_models.respond_to?(:destroy_all)
        default_models.destroy_all(model_primary_key => ids_to_remove)
      elsif @item_hash
        default_models.delete_if { |m| ids_to_remove.include? (m.key?(model_primary_key.to_sym) ? m[model_primary_key.to_sym] : m[model_primary_key.to_s]) }
      else
        default_models.delete_if { |m| ids_to_remove.include? m.send(model_primary_key) }
      end

      items_to_add.each do |item|
        default_models << model = (@model_class.is_a?(String) ? @model_class.constantize : @model_class).new
        item.save_to_models(models.merge(default: model))
      end
    end

    def to_hash
      self.map(&:to_hash)
    end

    def export_to_model_hash(models)
      self.each { |item| models[:default] << item.export_to_model_hash(models.merge(default: {}))[:default] }
      models
    end

    def hash_val(hash, key)
      hash.key?(key.to_sym) ? hash[key.to_sym] : hash[key.to_s]
    end
  end
end
