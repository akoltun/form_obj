require 'typed_array'

module FormObj
  class Struct
    class Array < TypedArray
      def create
        self << (item = create_item)
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

        ids_to_remove = self.map(&:primary_key) - ids_exists
        self.delete_if { |item| ids_to_remove.include? item.primary_key }

        items_to_add.each do |item|
          self.create.update_attributes(item, raise_if_not_found: raise_if_not_found)
        end

        sort! { |a, b| vals.index { |val| primary_key(val) == a.primary_key } <=> vals.index { |val| primary_key(val) == b.primary_key } }
      end

      private

      def create_item
        item_class.new
      end

      def primary_key(hash)
        hash[item_class.primary_key]
      end
    end
  end
end
