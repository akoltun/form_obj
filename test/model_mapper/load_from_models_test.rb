require "test_helper"

class ModelMapperLoadFromModelsTest < Minitest::Test
  EngineModel = Struct.new(:power, :volume)
  CarModel = Struct.new(:code, :driver, :engine)
  SponsorModel = Struct.new(:title, :money)
  SuspensionModel = Struct.new(:front, :rear)
  ChassisModel = Struct.new(:chassis)
  ColourModel = Struct.new(:name, :rgb)
  DriversChampionshipModel = Struct.new(:driver, :year)

  class TeamModel < Array
    attr_accessor :team_name, :year, :cars, :finance, :chassis, :drivers_championships
  end

  class Sponsor < FormObj::Form
    include FormObj::ModelMapper

    attribute :title
    attribute :money
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
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
    end
    attribute :sponsors, class: Sponsor, array: true, model_attribute: 'finance.:sponsors', primary_key: :title
    attribute :chassis, array: true, model_hash: true, model: :chassis do
      attribute :id
      attribute :suspension do
        attribute :front
        attribute :rear
      end
      attribute :brakes
    end
    attribute :colours, array: true, model_nesting: false, primary_key: :name do
      attribute :name
      attribute :rgb
    end
    attribute :drivers_championships, array: true, model_attribute: false, class: DriversChampionship, primary_key: :year
    attribute :constructors_championships, array: true, model_attribute: false, class: ConstructorsChampionship, primary_key: :year
  end

  def setup
    @team_model = TeamModel.new
    @chassis_model = ChassisModel.new

    @team = Team.new
  end

  def fill_in_models
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
    @team_model.drivers_championships = [
        DriversChampionshipModel.new('Ascari', 1952),
        DriversChampionshipModel.new('Hawthorn', 1958),
    ]

    @team_model.push(ColourModel.new('white', 0xFFFFFF))

    @chassis_model.chassis = [
        { id: 1, suspension: SuspensionModel.new('independant', 'de Dion'), brakes: :drum },
        { id: 2, suspension: SuspensionModel.new('dependant', 'de Dion'), brakes: :disc }
    ]
  end

  def fill_in_form
    @team.name = 'McLaren'
    @team.year = 1966

    car = @team.cars.create
    car.code = '340 F1'
    car.driver = 'Bruce McLaren'
    car.engine.power = 300
    car.engine.volume = 3.0

    car = @team.cars.create
    car.code = 'M7A'
    car.driver = 'Denis Hulme'
    car.engine.power = 415
    car.engine.volume = 4.3

    sponsor = @team.sponsors.create
    sponsor.title = 'Total'
    sponsor.money = 250

    sponsor = @team.sponsors.create
    sponsor.title = 'Shell'
    sponsor.money = 3000

    chassis = @team.chassis.create
    chassis.id = 2
    chassis.suspension.front = 'old'
    chassis.suspension.rear = 'very old'
    chassis.brakes = :hand

    colour = @team.colours.create
    colour.name = 'red'
    colour.rgb = 0xFF0000

    colour = @team.colours.create
    colour.name = 'green'
    colour.rgb = 0x00FF00

    colour = @team.colours.create
    colour.name = 'blue'
    colour.rgb = 0x0000FF

    drivers_championship = @team.drivers_championships.create
    drivers_championship.driver = 'Surtees'
    drivers_championship.year = 1964

    drivers_championship = @team.drivers_championships.create
    drivers_championship.driver = 'Rindt'
    drivers_championship.year = 1970

    constructors_championship = @team.constructors_championships.create
    constructors_championship.year = 1961

    constructors_championship = @team.constructors_championships.create
    constructors_championship.year = 1964
  end

  def test_that_load_from_model_returns_form_itself
    assert_same(@team, @team.load_from_model(@team_model))  
  end

  def test_that_all_attributes_value_are_correctly_loaded_from_empty_models_into_empty_form
    check_that_all_attributes_value_are_correctly_loaded_from_empty_models
    check_that_not_synched_attributes_are_still_empty
  end

  def test_that_all_attributes_value_are_correctly_loaded_from_empty_models_into_filled_form
    fill_in_form

    check_that_all_attributes_value_are_correctly_loaded_from_empty_models
    check_that_not_synched_attributes_keep_their_values
  end

  def test_that_all_attributes_value_are_correctly_loaded_from_filled_models_into_empty_form
    fill_in_models

    check_that_all_attributes_value_are_correctly_loaded_from_filled_models
    check_that_not_synched_attributes_are_still_empty
  end

  def test_that_all_attributes_value_are_correctly_loaded_from_filled_models_into_filled_form
    fill_in_models
    fill_in_form

    check_that_all_attributes_value_are_correctly_loaded_from_filled_models
    check_that_not_synched_attributes_keep_their_values
  end

  def check_that_not_synched_attributes_are_still_empty
    assert_kind_of(FormObj::ModelMapper::Array, @team.drivers_championships)
    assert_equal(0, @team.drivers_championships.size)

    assert_kind_of(FormObj::ModelMapper::Array, @team.constructors_championships)
    assert_equal(0, @team.constructors_championships.size)
  end

  def check_that_not_synched_attributes_keep_their_values
    assert_kind_of(FormObj::ModelMapper::Array, @team.drivers_championships)
    assert_equal(2, @team.drivers_championships.size)

    assert_equal('Surtees', @team.drivers_championships[0].driver)
    assert_equal(1964, @team.drivers_championships[0].year)

    assert_equal('Rindt', @team.drivers_championships[1].driver)
    assert_equal(1970, @team.drivers_championships[1].year)

    assert_kind_of(FormObj::ModelMapper::Array, @team.constructors_championships)
    assert_equal(2, @team.constructors_championships.size)
    assert_equal(1961, @team.constructors_championships[0].year)
    assert_equal(1964, @team.constructors_championships[1].year)
  end

  def check_that_all_attributes_value_are_correctly_loaded_from_empty_models
    @team.load_from_models(default: @team_model, chassis: @chassis_model)

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

  def check_that_all_attributes_value_are_correctly_loaded_from_filled_models
    @team.load_from_models(default: @team_model, chassis: @chassis_model)

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

    assert_equal(@chassis_model.chassis[0][:id], @team.chassis[0].id)
    assert_equal(@chassis_model.chassis[0][:suspension].front, @team.chassis[0].suspension.front)
    assert_equal(@chassis_model.chassis[0][:suspension].rear, @team.chassis[0].suspension.rear)
    assert_equal(@chassis_model.chassis[0][:brakes], @team.chassis[0].brakes)

    assert_equal(@chassis_model.chassis[1][:id], @team.chassis[1].id)
    assert_equal(@chassis_model.chassis[1][:suspension].front, @team.chassis[1].suspension.front)
    assert_equal(@chassis_model.chassis[1][:suspension].rear, @team.chassis[1].suspension.rear)
    assert_equal(@chassis_model.chassis[1][:brakes], @team.chassis[1].brakes)

    assert_kind_of(::Array, @team.colours)
    assert_equal(1, @team.colours.size)

    assert_equal(@team_model[0].name, @team.colours[0].name)
    assert_equal(@team_model[0].rgb, @team.colours[0].rgb)
  end
end