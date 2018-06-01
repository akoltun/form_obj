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

      private

      def create_item
        item_class.new
      end
    end
  end
end
