require 'tree_struct'

class TreeStruct
  class Attributes
    def initialize(items = [])
      @items = items
    end

    def add(attribute)
      self.class.new(@items + [attribute])
    end

    def map(*args, &block)
      @items.map(*args, &block)
    end
  end
end
