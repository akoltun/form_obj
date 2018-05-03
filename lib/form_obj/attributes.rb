require 'tree_struct'

module FormObj
  class Attributes < ::TreeStruct::Attributes
    def find(name)
      @items.find { |item| item.name == name.to_sym }
    end
  end
end
