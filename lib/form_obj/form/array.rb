module FormObj
  class Form < FormObj::Struct
    class Array < FormObj::Struct::Array
      def persisted?
        all?(&:persisted?)
      end

      def mark_as_persisted
        each(&:mark_as_persisted)
      end

      def mark_for_destruction
        each(&:mark_for_destruction)
      end

      def marked_for_destruction
        select(&:marked_for_destruction?)
      end

      private

      # Should return hash with 3 keys: :create, :update, :destroy
      # In default implementation:
      # :create - array of hashes of new attribute values
      # :update - hash where key is the item to update and value is a hash of new attribute values
      # :destroy - array of items to be destroyed
      def define_items_for_CUD(items)
        to_be_created = []
        to_be_updated = {}
        to_be_destroyed = []

        items.each do |item_hash|
          item_hash = HashWithIndifferentAccess.new(item_hash)
          _destroy = item_hash.delete(:_destroy)
          item = find_by_primary_key(primary_key(item_hash))
          if item
            if _destroy
              to_be_destroyed << item
            else
              to_be_updated[item] = item_hash
            end
          elsif !_destroy
            to_be_created << item_hash
          end
        end

        { create: to_be_created, update: to_be_updated, destroy: to_be_destroyed }
      end

      # items - array of items to be destroyed
      def destroy_items(items)
        items.each(&:mark_for_destruction)
      end
    end
  end
end
