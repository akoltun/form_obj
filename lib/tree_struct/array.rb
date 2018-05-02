require 'typed_array'

class TreeStruct
  class Array < TypedArray
    def create
      self << (item = item_class.new)
      item
    end

    def to_hash
      self.map(&:to_hash)
    end
  end
end
