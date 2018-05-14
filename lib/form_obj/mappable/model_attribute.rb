require 'active_support/inflector'
require 'form_obj/mappable/model_attribute/item'

module FormObj
  module Mappable
    class ModelAttribute
      attr_reader :model

      def initialize(names:, classes:, default_name:, array:, hash:, subform:, model:)
        @read_from_model = @write_to_model = !(names === false)

        @model = model
        @array = array

        names = (names || default_name).to_s.split('.') unless names.is_a? ::Enumerable
        classes = classes.nil? ? [] : [classes] unless classes.is_a? ::Enumerable

        if classes.size > 0
          if (subform && (names.size != classes.size)) || (!subform && (names.size != classes.size + 1))
            raise "Since the :model_attribute size is #{names.size} the :model_class size should be #{names.size - subform ? 0 : 1} in terms of nested items but it was #{classes.size}" unless names.size == classes.size
          end
        end

        @items = names.zip(classes, [hash], names[0..-2].map{nil} + [array]).map { |item| Item.new(name: item[0], klass: item[1], hash: item[2], array: item[3]) }

        @items.inject do |prev, item|
          prev.hash = true if item.hash_item
          item
        end
      end

      def last_name
        @items.last.name
      end

      def hash_item=(value)
        @items[0].hash_item = value
      end

      def create_model
        raise 'Creation available only for array attributes' unless @array
        @items.last.create_model
      end

      def read_from_model?
        @read_from_model
      end

      def read_from_model(model, create_nested_model_if_nil: false)
        @items.reduce(model) { |last_model, item| item.read_from_model(last_model, create_nested_model_if_nil: create_nested_model_if_nil) }
      end

      def read_from_models(models, create_nested_model_if_nil: false)
        read_from_model(models[@model], create_nested_model_if_nil: create_nested_model_if_nil)
      end

      def write_to_model?
        @write_to_model
      end

      def write_to_model(model, value)
        model = @items[0..-2].reduce(model) { |last_model, item| item.read_from_model(last_model, create_nested_model_if_nil: true) } if @items.size > 1
        @items.last.write_to_model(model, value)
      end

      def write_to_models(models, value)
        write_to_model(models[@model], value)
      end

      def validate_primary_key!
        if @items.size > 1
          raise PrimaryKeyMappingError.new('Primary key should not be mapped to nested model')
        elsif @items.size == 0
          raise PrimaryKeyMappingError.new('Primary key should not be mapped to non-mapped attribute')
        end
      end

      def to_model_hash(value)
        @items.reverse.reduce(value) { |value, item| item.to_hash(value) }
      end
    end
  end
end