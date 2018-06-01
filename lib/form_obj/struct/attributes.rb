module FormObj
  class Struct
    class Attributes
      def initialize(items = [])
        @items = items
      end

      def add(attribute)
        if @items.map(&:name).include? attribute.name
          self.class.new(@items.map { |item| item.name == attribute.name ? attribute : item })
        else
          self.class.new(@items + [attribute])
        end
      end

      def map(*args, &block)
        @items.map(*args, &block)
      end
    end
  end
end
