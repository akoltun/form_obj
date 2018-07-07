require "test_helper"

class ModelMapperCustomLoadFromModelTest < Minitest::Test
  class ArrayLoadLimit < FormObj::ModelMapper::Array
    private

    def iterate_through_models_to_load_them(models, params = {}, &block)
      models = models.slice(params[:offset] || 0, params[:limit] || 999999999) if model_attribute.names.last == :cars
      super(models, &block)
    end
  end

  class LoadLimitForm < FormObj::Form
    include FormObj::ModelMapper

    def self.array_class
      ArrayLoadLimit
    end
  end

  class Team < LoadLimitForm
    include FormObj::ModelMapper

    attribute :name, model_attribute: :team_name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
    end
    attribute :colours, array: true, primary_key: :name do
      attribute :name
      attribute :rgb
    end
  end

  CarModel = Struct.new(:code, :driver)
  ColourModel = Struct.new(:name, :rgb)

  def setup
    cars_model = [CarModel.new('340 F1', 'Ascari'), CarModel.new('275 F1', 'Villoresi')]
    colours_model = [ColourModel.new(:red, 0xFF0000), ColourModel.new(:white, 0xFFFFFF)]
    @team_model = Struct.new(:team_name, :year, :cars, :colours).new('Ferrari', 1950, cars_model, colours_model)

    @team = Team.new
  end

  def test_that_it_loads_first_group_of_elements
    @team.load_from_model(@team_model, offset: 0, limit: 1)

    assert_equal('Ferrari', @team.name)
    assert_equal(1950, @team.year)

    assert_equal(1, @team.cars.size)
    assert_equal('340 F1', @team.cars[0].code)
    assert_equal('Ascari', @team.cars[0].driver)

    assert_equal(2, @team.colours.size)

    assert_equal(:red, @team.colours[0].name)
    assert_equal(0xFF0000, @team.colours[0].rgb)

    assert_equal(:white, @team.colours[1].name)
    assert_equal(0xFFFFFF, @team.colours[1].rgb)
  end

  def test_that_it_loads_second_group_of_elements
    @team.load_from_model(@team_model, offset: 1, limit: 1)

    assert_equal('Ferrari', @team.name)
    assert_equal(1950, @team.year)

    assert_equal(1, @team.cars.size)
    assert_equal('275 F1', @team.cars[0].code)
    assert_equal('Villoresi', @team.cars[0].driver)

    assert_equal(2, @team.colours.size)

    assert_equal(:red, @team.colours[0].name)
    assert_equal(0xFF0000, @team.colours[0].rgb)

    assert_equal(:white, @team.colours[1].name)
    assert_equal(0xFFFFFF, @team.colours[1].rgb)
  end
end