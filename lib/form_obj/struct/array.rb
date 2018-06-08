require 'typed_array'

module FormObj
  class Struct
    class Array < TypedArray
      def create(hash = nil, raise_if_not_found: true)
        self << (item = create_item(hash, raise_if_not_found: raise_if_not_found))
        item
      end

      def to_hash
        self.map(&:to_hash)
      end

      def update_attributes(vals, raise_if_not_found:)
        ids_exists = []
        items_to_add = []

        vals.each do |val|
          id = primary_key(HashWithIndifferentAccess.new(val))
          item = self.find { |i| i.primary_key == id }
          if item
            item.update_attributes(val, raise_if_not_found: raise_if_not_found)
            ids_exists << id
          else
            items_to_add << val
          end
        end

        delete_items(self.map(&:primary_key) - ids_exists)

        items_to_add.each do |item|
          self << create_item(item, raise_if_not_found: raise_if_not_found)
        end

        sort! { |a, b| (vals.index { |val| primary_key(val) == a.primary_key } || -1) <=> (vals.index { |val| primary_key(val) == b.primary_key } || -1) }
      end

      private

      def delete_items(ids)
        self.delete_if { |item| ids.include? item.primary_key }
      end

      def create_item(hash, raise_if_not_found:)
        item_class.new(hash, raise_if_not_found: raise_if_not_found)
      end

      def primary_key(hash)
        hash[item_class.primary_key]
      end
    end
  end
end
