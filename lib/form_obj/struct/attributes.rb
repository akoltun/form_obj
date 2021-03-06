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

      def each(&block)
        @items.each(&block)
      end

      def find(name)
        @items.find { |item| item.name == name.to_sym }
      end

      def map(*args, &block)
        @items.map(*args, &block)
      end

      def reduce(*args, &block)
        @items.reduce(*args, &block)
      end
    end
  end
end
