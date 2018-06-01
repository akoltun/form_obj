require 'active_support/inflector'

module FormObj
  module ModelMapper
    class ModelAttribute
      private

      class Item
        attr_accessor :hash
        attr_reader :hash_item, :name

        def initialize(name:, klass:, hash:, array:)
          @array = array
          @hash = hash
          @hash_item = name[0] == ':'
          @name = (name[0] == ':' ? name[1..-1] : name).to_sym
          @klass = klass || @name.to_s.classify
        end

        def hash_item=(value)
          @hash_item ||= value
        end

        def create_model
          if @hash
            {}
          else
            (@klass.is_a?(String) ? @klass.constantize : @klass).try(:new)
          end
        end

        def create_array
          []
        end

        def read_from_model(model, create_nested_model_if_nil: false)
          return nil if model.nil?

          result = if @hash_item
                     model[hash_attribute_name(model, @name)]
                   else
                     model.send(@name)
                   end

          if result.nil? && create_nested_model_if_nil
            result = @array ? create_array : create_model
            write_to_model(model, result)
          end

          result
        end

        def write_to_model(model, value)
          if @hash_item
            model[hash_attribute_name(model, @name)] = value
          else
            model.send("#{@name}=", value)
          end
        end

        def to_hash(value)
          { @name => value }
        end

        def read_errors_from_model(model)
          @hash_item ? [] : model.errors[@name]
        end

        private

        def hash_attribute_name(model, name)
          model.key?(name.to_s) && !model.key?(name.to_sym) ? name.to_s : name.to_sym
        end
      end
    end
  end
end