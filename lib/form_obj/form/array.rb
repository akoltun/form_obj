module FormObj
  class Form < FormObj::Struct
    class Array < FormObj::Struct::Array
      def persisted?
        all?(&:persisted?)
      end

      def mark_as_persisted
        each(&:mark_as_persisted)
      end

      private

      # items_to_add - array of hashes of new attribute values
      # items_to_update - hash where key is the item to update and value is a hash of new attribute values
      def items_for_destruction(items_to_add:, items_to_update:)
        items_to_update.select { |item, attr_values| attr_values[:_destroy] }.keys
      end

      # items - array of items to be destroyed
      def destroy_items(items)
        items.each(&:mark_for_destruction)
      end

      # items - hash where key is the item to update and value is a hash of new attribute values
      # params - additional params for :update_attributes method
      def update_items(items, params)
        items.each_pair { |item, attr_values| item.update_attributes(attr_values, params) unless attr_values.delete(:_destroy) }
      end
    end
  end
end
