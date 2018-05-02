class TreeStruct
  class Attribute
    attr_reader :name

    def initialize(name, array: false, class: nil, default: nil, parent:, &block)
      @name = name.to_sym
      @array = array
      @default_value = default
      @parent = parent

      @nested_class = binding.local_variable_get(:class)
      @nested_class = Class.new(@parent.nested_class, &block) if !@nested_class && block_given?

      raise 'Nested structure has to be defined (either with :class parameter or with block) for arrays if :default parameter is not specified' if @array && @nested_class.nil? && @default_value.nil?
    end

    def subform?
      !@nested_class.nil?
    end

    def validate_value!(value)
      if @nested_class
        if @array
          unless value.class == @parent.array_class
            raise ArgumentError.new(":#{@name} attribute value should be of class #{@parent.nested_class.name}::Array while attempt to assign value of class #{value.class.name}")
          end
          unless value.item_class == @nested_class
            raise ArgumentError.new(":#{@name} attribute value should be an array with items of class #{@nested_class.name} while attempt to assign an array with items of class #{value.item_class.name}")
          end

        else
          unless value.class == @nested_class
            raise ArgumentError.new(":#{@name} attribute value should be of class #{@nested_class.name} while attempt to assign value of class #{value.class.name}")
          end
        end
      end
    end

    def default_value
      if @default_value.nil?
        if @nested_class
          if @array
            @parent.array_class.new(@nested_class)
          else
            @nested_class.new
          end
        end

      elsif @default_value.is_a? Proc
        @default_value.call(@parent, self)

      else
        @default_value
      end
    end
  end
end
