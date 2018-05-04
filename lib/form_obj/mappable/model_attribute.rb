module FormObj
  module Mappable
    class ModelAttribute
      def initialize(names, default_name, hash: false)
        @items = if names === false
                   []
                 elsif names.is_a? ::Enumerable
                   names
                 else
                   items = (names || default_name).to_s.split('.')
                   [Item.new(items[0], hash: hash)] + items[1..-1].map { |item| Item.new(item) }
                 end
      end

      def hash=(value)
        @items[0].hash ||= value
      end

      def read_from_model(model)
        @items.reduce(model) { |last_model, item| item.read_from_model(last_model) }
      end

      def present?
        @items.size > 0
      end

      private

      class Item
        attr_accessor :hash

        def initialize(name, hash: false)
          @hash = hash || name[0] == ':'
          @name = (name[0] == ':' ? name[1..-1] : name).to_sym
        end

        def read_from_model(model, nested_form_class: nil)
          return nil if model.nil?

          result = if @hash
                     model[@name].nil? ? model[@name.to_s] : model[@name]
                   else
                     model.send(@name)
                   end

          # if result.nil? && nested_form_class
          #   result = (nested_form_class.is_a?(String) ? nested_form_class.constantize : nested_form_class).try(:new)
          #   if @hash
          #     model[@name] = result
          #   else
          #     model.send("#{@name}=", result)
          #   end
          # end

          result
        end
      end
    end
  end
end