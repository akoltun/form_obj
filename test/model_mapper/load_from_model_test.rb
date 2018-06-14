require "test_helper"

class ModelMapperLoadFromModelTest < Minitest::Test
  EngineModel = Struct.new(:power, :volume)
  CarModel = Struct.new(:code, :driver, :engine)
  SponsorModel = Struct.new(:title, :money)
  SuspensionModel = Struct.new(:front, :rear)
  ColourModel = Struct.new(:name, :rgb)
  DriversChampionshipModel = Struct.new(:driver, :year)

  class TeamModel < Array
    attr_accessor :team_name, :year, :cars, :finance, :chassis, :drivers_championships
  end

  class DriversChampionship < FormObj::Form
    include FormObj::ModelMapper

    attribute :driver
    attribute :year
  end

  class ConstructorsChampionship < FormObj::Form
    include FormObj::ModelMapper

    attribute :year
  end

  class Team < FormObj::Form
    include FormObj::ModelMapper

    attribute :name, model_attribute: :team_name
    attribute :year
    attribute :cars, array: true do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
    end
    attribute :sponsors, array: true, model_attribute: 'finance.:sponsors' do
      attribute :title
      attribute :money
    end
    attribute :chassis, array: true, model_hash: true do
      attribute :suspension do
        attribute :front
        attribute :rear
      end
      attribute :brakes
    end
    attribute :colours, array: true, model_nesting: false do
      attribute :name
      attribute :rgb
    end
    attribute :drivers_championships, array: true, model_attribute: false, class: DriversChampionship
    attribute :constructors_championships, array: true, model_attribute: false, class: ConstructorsChampionship
  end

  def setup
    @team_model = TeamModel.new
    @team = Team.new
  end

  def fill_in_model
    @team_model.team_name = 'Ferrari'
    @team_model.year = 1950
    @team_model.cars = [
        CarModel.new('340 F1', 'Ascari', EngineModel.new(335, 4.1)),
        CarModel.new('275 F1', 'Villoresi', EngineModel.new(300, 3.3)),
    ]
    @team_model.finance = {
        sponsors: [
            SponsorModel.new('Shell', 1000000),
            SponsorModel.new('Pirelli', 500000),
        ]
    }
    @team_model.chassis = [
        { suspension: SuspensionModel.new('independant', 'de Dion'), brakes: :drum },
        { suspension: SuspensionModel.new('dependant', 'de Dion'), brakes: :disc }
    ]
    @team_model.drivers_championships = [
        DriversChampionshipModel.new('Ascari', 1952),
        DriversChampionshipModel.new('Hawthorn', 1958),
    ]

    @team_model.push(ColourModel.new('red', 0xFF0000), ColourModel.new('green', 0x00FF00), ColourModel.new('blue', 0x0000FF))
  end

  def test_that_load_from_model_returns_form_itself
    assert_same(@team, @team.load_from_model(@team_model))  
  end

  def test_that_all_attributes_value_are_correctly_loaded_from_filled_model_into_empty_form
    check_that_all_attributes_value_are_correctly_loaded_from_filled_model
  end

  def test_that_all_attributes_value_are_correctly_loaded_from_filled_model_into_filled_form
    2.times { @team.cars.build }

    check_that_all_attributes_value_are_correctly_loaded_from_filled_model
  end

  def test_that_all_attributes_value_are_correctly_loaded_from_filled_model_into_empty_form
    check_that_all_attributes_value_are_correctly_loaded_from_filled_model
  end

  def test_that_all_attributes_value_are_correctly_loaded_from_filled_model_into_filled_form
    2.times { @team.cars.build }

    check_that_all_attributes_value_are_correctly_loaded_from_empty_model
  end

  def check_that_all_attributes_value_are_correctly_loaded_from_empty_model
    @team.load_from_model(@team_model)

    assert_nil(@team.name)
    assert_nil(@team.year)

    assert_kind_of(FormObj::ModelMapper::Array, @team.cars)
    assert_equal(0, @team.cars.size)

    assert_kind_of(FormObj::ModelMapper::Array, @team.sponsors)
    assert_equal(0, @team.sponsors.size)

    assert_kind_of(FormObj::ModelMapper::Array, @team.chassis)
    assert_equal(0, @team.chassis.size)

    assert_kind_of(FormObj::ModelMapper::Array, @team.colours)
    assert_equal(0, @team.colours.size)
  end

  def check_that_all_attributes_value_are_correctly_loaded_from_filled_model
    fill_in_model
    @team.load_from_model(@team_model)

    assert_equal(@team_model.team_name, @team.name)
    assert_equal(@team_model.year, @team.year)

    assert_kind_of(FormObj::ModelMapper::Array, @team.cars)
    assert_equal(2, @team.cars.size)

    assert_equal(@team_model.cars[0].code, @team.cars[0].code)
    assert_equal(@team_model.cars[0].driver, @team.cars[0].driver)
    assert_equal(@team_model.cars[0].engine.power, @team.cars[0].engine.power)
    assert_equal(@team_model.cars[0].engine.volume, @team.cars[0].engine.volume)

    assert_equal(@team_model.cars[1].code, @team.cars[1].code)
    assert_equal(@team_model.cars[1].driver, @team.cars[1].driver)
    assert_equal(@team_model.cars[1].engine.power, @team.cars[1].engine.power)
    assert_equal(@team_model.cars[1].engine.volume, @team.cars[1].engine.volume)

    assert_kind_of(FormObj::ModelMapper::Array, @team.sponsors)
    assert_equal(2, @team.sponsors.size)

    assert_equal(@team_model.finance[:sponsors][0].title, @team.sponsors[0].title)
    assert_equal(@team_model.finance[:sponsors][0].money, @team.sponsors[0].money)

    assert_equal(@team_model.finance[:sponsors][1].title, @team.sponsors[1].title)
    assert_equal(@team_model.finance[:sponsors][1].money, @team.sponsors[1].money)

    assert_kind_of(FormObj::ModelMapper::Array, @team.chassis)
    assert_equal(2, @team.chassis.size)

    assert_equal(@team_model.chassis[0][:suspension].front, @team.chassis[0].suspension.front)
    assert_equal(@team_model.chassis[0][:suspension].rear, @team.chassis[0].suspension.rear)
    assert_equal(@team_model.chassis[0][:brakes], @team.chassis[0].brakes)

    assert_equal(@team_model.chassis[1][:suspension].front, @team.chassis[1].suspension.front)
    assert_equal(@team_model.chassis[1][:suspension].rear, @team.chassis[1].suspension.rear)
    assert_equal(@team_model.chassis[1][:brakes], @team.chassis[1].brakes)

    assert_equal(Array.new, @team.drivers_championships)
    assert_equal(Array.new, @team.constructors_championships)

    assert_kind_of(FormObj::ModelMapper::Array, @team.colours)
    assert_equal(3, @team.colours.size)

    assert_equal(@team_model[0].name, @team.colours[0].name)
    assert_equal(@team_model[0].rgb, @team.colours[0].rgb)

    assert_equal(@team_model[1].name, @team.colours[1].name)
    assert_equal(@team_model[1].rgb, @team.colours[1].rgb)

    assert_equal(@team_model[2].name, @team.colours[2].name)
    assert_equal(@team_model[2].rgb, @team.colours[2].rgb)
  end
end