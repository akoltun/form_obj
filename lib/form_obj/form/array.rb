require 'tree_struct'

module FormObj
  class Form < ::TreeStruct
    class Array < ::TreeStruct::Array
      def update_attributes(vals)
        ids_exists = []
        items_to_add = []

        vals.each do |val|
          id = primary_key(val)
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

        sort! { |a, b| vals.index { |val| primary_key(val) == a.primary_key } <=> vals.index { |val| primary_key(val) == b.primary_key } }
      end

      private

      def primary_key(hash)
        hash.key?(item_class.primary_key.to_sym) ? hash[item_class.primary_key.to_sym] : hash[item_class.primary_key.to_s]
      end
    end
  end
end
