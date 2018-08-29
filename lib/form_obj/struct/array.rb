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

      def update_attributes(items, raise_if_not_found:)
        items_for_CUD = define_items_for_CUD(items)

        destroy_items(items_for_CUD[:destroy])
        update_items(items_for_CUD[:update], raise_if_not_found: raise_if_not_found)
        build_items(items_for_CUD[:create], raise_if_not_found: raise_if_not_found)

        resort_items_after_CUD!(items)
      end

      def eql?(array)
        array.is_a?(self.class) && size == array.size && all? { |item| item == array.find_by_primary_key(item.primary_key) }
      end

      def ==(array)
        array.is_a?(Enumerable) && size == array.count && all? { |item| (array_item = array.find { |ai| ai.respond_to?(item_class.primary_key) && ai.send(item_class.primary_key) == item.primary_key }) && item == array_item }
      end

      protected

      def find_by_primary_key(id)
        find { |item| item.primary_key == id }
      end

      private

      def primary_key(hash)
        hash[item_class.primary_key]
      end

      # Should return hash with 3 keys: :create, :update, :destroy
      # In default implementation:
      # :create - array of hashes of new attribute values
      # :update - hash where key is the item to update and value is a hash of new attribute values
      # :destroy - array of items to be destroyed
      def define_items_for_CUD(items)
        to_be_created = []
        to_be_updated = {}

        items.each do |item_hash|
          item_hash = HashWithIndifferentAccess.new(item_hash)
          item = find_by_primary_key(primary_key(item_hash))
          if item
            to_be_updated[item] = item_hash
          else
            to_be_created << item_hash
          end
        end
        to_be_destroyed = self - to_be_updated.keys

        { create: to_be_created, update: to_be_updated, destroy: to_be_destroyed }
      end

      # Resort items so they will be in the same order as in the update_attributes parameter
      # items - hash received by update_attributes
      def resort_items_after_CUD!(items)
        sort! { |a, b| (items.index { |val| primary_key(val) == a.primary_key } || -1) <=> (items.index { |val| primary_key(val) == b.primary_key } || -1) }
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

      def build_item(hash, raise_if_not_found:)
        item_class.new(hash, raise_if_not_found: raise_if_not_found)
      end
    end
  end
end
