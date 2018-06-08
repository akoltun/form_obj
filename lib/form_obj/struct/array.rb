require 'typed_array'

module FormObj
  class Struct
    class Array < TypedArray
      def build(hash = nil, raise_if_not_found: true)
        self << (item = build_item(hash, raise_if_not_found: raise_if_not_found))
        item
      end

      def create(*args)
        build(*args)
      end

      def to_hash
        self.map(&:to_hash)
      end

      def update_attributes(vals, raise_if_not_found:)
        items_to_add = []
        items_to_update = {}

        vals.each do |val|
          val = HashWithIndifferentAccess.new(val)
          item = find_by_primary_key(primary_key(val))
          if item
            items_to_update[item] = val
          else
            items_to_add << val
          end
        end
        items_to_destroy = items_for_destruction(items_to_add: items_to_add, items_to_update: items_to_update)

        destroy_items(items_to_destroy)
        update_items(items_to_update, raise_if_not_found: raise_if_not_found)
        build_items(items_to_add, raise_if_not_found: raise_if_not_found)

        sort! { |a, b| (vals.index { |val| primary_key(val) == a.primary_key } || -1) <=> (vals.index { |val| primary_key(val) == b.primary_key } || -1) }
      end

      private

      def primary_key(hash)
        hash[item_class.primary_key]
      end

      def find_by_primary_key(id)
        find { |item| item.primary_key == id }
      end

      def build_item(hash, raise_if_not_found:)
        item_class.new(hash, raise_if_not_found: raise_if_not_found)
      end

      # items_to_add - array of hashes of new attribute values
      # items_to_update - hash where key is the item to update and value is a hash of new attribute values
      def items_for_destruction(items_to_add:, items_to_update:)
        self - items_to_update.keys
      end

      # items - array of items to be destroyed
      def destroy_items(items)
        items.each { |item| delete(item) }
      end

      # items - hash where key is the item to update and value is a hash of new attribute values
      # params - additional params for :update_attributes method
      def update_items(items, params)
        items.each_pair { |item, attr_values| item.update_attributes(attr_values, params) }
      end

      # items - array of hashes of new attribute values
      # params - additional params for constructor
      def build_items(items, params)
        items.each { |item| self << build_item(item, params) }
      end
    end
  end
end
