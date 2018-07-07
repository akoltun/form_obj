module FormObj
  class Struct
    class Attribute
      attr_reader :name

      def initialize(name, array: false, class: nil, default: nil, parent:, primary_key: nil, &block)
        @name = name.to_sym
        @array = array
        @default_value = default
        @parent = parent

        @nested_class = binding.local_variable_get(:class)
        @nested_class = @nested_class.constantize if @nested_class.is_a? String
        @nested_class = Class.new(@parent.nested_class, &block) if !@nested_class && block_given?

        raise ArgumentError.new('Nested structure has to be defined (either with :class parameter or with block) for arrays if :default parameter is not specified') if @array && @nested_class.nil? && @default_value.nil?

        if primary_key
          if @nested_class
            @nested_class.primary_key = primary_key
          else
            parent.primary_key = name.to_sym
          end
        end

        if @array && @nested_class._attributes.find(@nested_class.primary_key).nil?
          raise FormObj::NonexistentPrimaryKeyError.new("#{@nested_class.inspect} has no attribute :#{@nested_class.primary_key} which is specified/defaulted as primary key")
        end
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
              create_array
            else
              create_nested
            end
          end

        else
          value = if @default_value.is_a? ::Proc
                    @default_value.call(@parent, self)
                  else
                    @default_value
                  end

          if @nested_class
            if @array
              raise FormObj::WrongDefaultValueClassError unless value.is_a? ::Array
              value = create_array(value.map do |val|
                val = create_nested(val) if val.is_a?(::Hash)
                raise FormObj::WrongDefaultValueClassError if val.class != @nested_class
                val
              end)
            else
              value = create_nested(value) if value.is_a? ::Hash
              raise FormObj::WrongDefaultValueClassError if value.class != @nested_class
            end
          end

          value
        end
      end

      private

      def create_nested(*args)
        @nested_class.new(*args)
      end

      def create_array(*args)
        @parent.array_class.new(@nested_class, *args)
      end
    end
  end
end
