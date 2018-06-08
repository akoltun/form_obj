require "test_helper"

class StructUpdateAttributesRedefineCreateUpdateDeleteMethodsTest < Minitest::Test
  class MyStruct < FormObj::Struct
    class Array < FormObj::Struct::Array
      private

      def destroy_items(items)
        items.each { |item| item._destroy = true; puts "Mark element #{item.primary_key} for destruction" }
      end

      def update_items(items, params)
        items.each_pair { |item, attr_values| puts "Update element #{item.primary_key} with #{attr_values}" }
        super
      end

      def build_items(items, params)
        items.each { |item| puts "Create new element from #{item}" }
        super
      end
    end

    def self.array_class
      Array
    end

    def self.nested_class
      MyStruct
    end

    private

    def update_attribute(attribute, new_value)
      puts "Update attribute :#{attribute.name} value from #{send(attribute.name)} to #{new_value}"
      super
    end
  end

  class Team < MyStruct
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :_destroy, default: false
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
    end
  end

  def test_that_new_methods_are_used
    team = nil

    assert_output(
        "Update attribute :name value from  to Ferrari\n" +
            "Create new element from {\"code\"=>\"340 F1\"}\n" +
            "Create new element from {\"code\"=>\"275 F1\"}\n" +
            "Update attribute :code value from  to 340 F1\n" +
            "Update attribute :code value from  to 275 F1\n"
    ) do
      team = Team.new(name: 'Ferrari', cars: [{ code: '340 F1' }, { code: '275 F1' }])
    end

    assert_output(
        "Mark element 340 F1 for destruction\n" +
        "Update element 275 F1 with {\"code\"=>\"275 F1\"}\n" +
        "Update attribute :code value from 275 F1 to 275 F1\n"
    ) do
      team.update_attributes(cars: [{ code: '275 F1' }])
    end
  end
end
