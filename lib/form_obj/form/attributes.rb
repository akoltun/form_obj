module FormObj
  class Form < FormObj::Struct
    class Attributes < FormObj::Struct::Attributes
      def find(name)
        @items.find { |item| item.name == name.to_sym }
      end

      def each(&block)
        @items.each(&block)
      end
    end
  end
end
