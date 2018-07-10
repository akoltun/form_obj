require "test_helper"

class ModelMapperCustomizeSyncToModelsTest < Minitest::Test
  class MyForm < FormObj::Form
    class Array < FormObj::ModelMapper::Array
      private

      def sync_destruction_to_models(models, ids_to_destroy)
        if models[:default].respond_to? :where
          models[:default].where(model_primary_key.name => ids_to_destroy).each { |model| puts "Mark for deletion model #{model}" }
        else
          models[:default].select { |model| ids_to_destroy.include? model_primary_key.read_from_model(model) }.each { |model| puts "Delete model #{model}" }
        end
        super
      end

      def sync_update_to_models(models, items_to_update)
        items_to_update.each_pair do |model, form_object|
          puts "Update model #{model} with #{form_object.to_model_hash}"
        end
        super
      end

      def sync_creation_to_models(models, form_objects_to_create)
        form_objects_to_create.each do |form_object|
          puts "Create model from #{form_object.to_model_hash}"
        end
        super
      end
    end

    include FormObj::ModelMapper

    def self.array_class
      Array
    end

    def self.nested_class
      MyForm
    end
  end

  TeamModel = Struct.new(:name, :cars)
  CarModel = Struct.new(:code, :driver)

  class Team < MyForm
    attribute :name
    attribute :cars, array: true, primary_key: :code, model_class: CarModel do
      attribute :code
      attribute :driver
    end
  end

  def setup
    @team_model = TeamModel.new('Ferrari', [CarModel.new('275 F1', 'Ascari'), CarModel.new('340 F1', 'Villoresi'), CarModel.new('M7A', 'Bruce McLaren')])
    @team = Team.new(
        name: 'McLaren',
        cars: [
                  { code: '340 F1', driver: 'Hunt' },
                  { code: 'M7A', driver: 'Farina' },
                  { code: 'M3A', driver: 'Clark' }
              ]
    ).update_attributes(cars: [{ code: 'M7A', _destroy: true }])
  end

  def test_that_new_methods_are_used
    assert_output(
        "Delete model #<struct ModelMapperCustomizeSyncToModelsTest::CarModel code=\"M7A\", driver=\"Bruce McLaren\">\n" +
            "Update model #<struct ModelMapperCustomizeSyncToModelsTest::CarModel code=\"340 F1\", driver=\"Villoresi\"> with {:code=>\"340 F1\", :driver=>\"Hunt\"}\n" +
            "Create model from {:code=>\"M3A\", :driver=>\"Clark\"}\n"
    ) do
      @team.sync_to_model(@team_model)
    end
  end
end
