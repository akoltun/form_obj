require "test_helper"

class UpdateAttributesRedefineCreateUpdateDeleteMethodsTest < Minitest::Test
  class MyStruct < FormObj::Struct
    class Array < FormObj::Struct::Array
      private

      def create_item(hash, raise_if_not_found:)
        puts "Create new element from #{hash}"
        super
      end

      def delete_items(ids)
        each do |item|
          if ids.include? item.primary_key
            item._destroy = true
            puts "Mark item #{item.primary_key} for deletion"
          end
        end
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
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
      attr_accessor :_destroy
    end
  end

  def test_that_new_methods_are_used
    team = nil

    assert_output(
        "Update attribute :name value from  to Ferrari\n" +
            "Create new element from {\"code\"=>\"340 F1\"}\n" +
            "Update attribute :code value from  to 340 F1\n" +
            "Create new element from {\"code\"=>\"275 F1\"}\n" +
            "Update attribute :code value from  to 275 F1\n"
    ) do
      team = Team.new(name: 'Ferrari', cars: [{ code: '340 F1' }, { code: '275 F1' }])
    end

    assert_output(
        "Update attribute :code value from 275 F1 to 275 F1\n" +
            "Mark item 340 F1 for deletion\n"
    ) do
      team.update_attributes(cars: [{ code: '275 F1' }])
    end
  end
end
