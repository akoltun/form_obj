require "test_helper"

Suspension = Struct.new(:front, :rear)

class ModelMapperSyncToModelTest < Minitest::Test
  EngineModel = Struct.new(:power, :volume)
  CarModel = Struct.new(:code, :driver, :engine)
  SponsorModel = Struct.new(:title, :money)
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
    attribute :cars, array: true, primary_key: :code, model_class: CarModel do
      attribute :code
      attribute :driver
      attribute :engine, model_class: EngineModel do
        attribute :power
        attribute :volume
      end
    end
    attribute :sponsors, class: Sponsor, array: true, model_attribute: 'finance.:sponsors', primary_key: :title, model_class: [Hash, SponsorModel]
    attribute :chassis, array: true, model_hash: true do
      attribute :id
      attribute :suspension do
        attribute :front
        attribute :rear
      end
      attribute :brakes
    end
    attribute :colours, array: true, model_nesting: false, primary_key: :name, model_class: ColourModel do
      attribute :name
      attribute :rgb
    end
    attribute :drivers_championships, array: true, model_attribute: false, class: DriversChampionship, primary_key: :year
    attribute :constructors_championships, array: true, model_attribute: false, class: ConstructorsChampionship, primary_key: :year
  end

  def setup
    @team_model = TeamModel.new
    @team = Team.new
  end

  def fill_in_model
    @team_model.team_name = 'Ferrari'
    @team_model.year = 1950
    @team_model.cars = [
        CarModel.new('340 F1', 'Ascari', EngineModel.new(335, 3.0)),
        CarModel.new('275 F1', 'Villoresi', EngineModel.new(300, 3.3)),
    ]
    @team_model.finance = {
        sponsors: [
            SponsorModel.new('Shell', 1000000),
            SponsorModel.new('Pirelli', 500000),
        ]
    }
    @team_model.chassis = [{ id: 2, suspension: Suspension.new('old', 'very old'), brakes: :hand }]
    @team_model.drivers_championships = [
        DriversChampionshipModel.new('Ascari', 1952),
        DriversChampionshipModel.new('Hawthorn', 1958),
    ]

    @team_model.push(ColourModel.new('red', 0xFF0000), ColourModel.new('green', 0x00FF00), ColourModel.new('blue', 0x0000FF))
  end

  def fill_in_form
    @team.name = 'McLaren'
    @team.year = 1966

    car = @team.cars.create
    car.code = '340 F1'
    car.driver = 'Bruce McLaren'
    car.engine.power = 300
    car.engine.volume = nil

    car = @team.cars.create
    car.code = 'M7A'
    car.driver = 'Denis Hulme'
    car.engine.power = 415
    car.engine.volume = 4.3

    sponsor = @team.sponsors.create
    sponsor.title = 'Shell'
    sponsor.money = 250

    sponsor = @team.sponsors.create
    sponsor.title = 'Total'
    sponsor.money = 3000

    chassis = @team.chassis.create
    chassis.id = 1
    chassis.suspension.front = 'independent'
    chassis.suspension.rear = 'de Dion'
    chassis.brakes = :drum

    chassis = @team.chassis.create
    chassis.id = 3
    chassis.suspension.front = 'dependent'
    chassis.suspension.rear = 'de Lion'
    chassis.brakes = :disc

    colour = @team.colours.create
    colour.name = 'white'
    colour.rgb = 0xFFFFFF

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

  def test_that_sync_to_model_returns_form_itself
    assert_same(@team, @team.sync_to_model(@team_model))
  end

  def test_that_all_attributes_value_are_correctly_synced_from_empty_form_into_empty_model
    check_that_all_attributes_value_are_correctly_synced_from_empty_form
    check_that_not_synced_attributes_are_still_empty
  end

  def test_that_all_attributes_value_are_correctly_synced_from_empty_form_into_filled_model
    fill_in_model

    check_that_all_attributes_value_are_correctly_synced_from_empty_form
    check_that_not_synced_attributes_keep_their_values
  end

  def test_that_all_attributes_value_are_correctly_synced_from_filled_form_into_empty_model
    fill_in_form

    check_that_all_attributes_value_are_correctly_synced_from_filled_form
    check_that_not_synced_attributes_are_still_empty
  end

  def test_that_all_attributes_value_are_correctly_synced_from_filled_form_into_filled_model
    fill_in_form
    fill_in_model

    check_that_all_attributes_value_are_correctly_synced_from_filled_form
    check_that_not_synced_attributes_keep_their_values
  end

  def check_that_not_synced_attributes_are_still_empty
    assert_nil(@team_model.drivers_championships)
  end

  def check_that_not_synced_attributes_keep_their_values
    assert_kind_of(::Array, @team_model.drivers_championships)
    assert_equal(2, @team_model.drivers_championships.size)

    assert_equal('Ascari', @team_model.drivers_championships[0].driver)
    assert_equal(1952, @team_model.drivers_championships[0].year)

    assert_equal('Hawthorn', @team_model.drivers_championships[1].driver)
    assert_equal(1958, @team_model.drivers_championships[1].year)
  end

  def check_that_all_attributes_value_are_correctly_synced_from_empty_form
    @team.sync_to_model(@team_model)

    assert_nil(@team_model.team_name)
    assert_nil(@team_model.year)

    assert_kind_of(::Array, @team_model.cars)
    assert_equal(0, @team_model.cars.size)

    assert_kind_of(::Array, @team_model.finance[:sponsors])
    assert_equal(0, @team_model.finance[:sponsors].size)

    assert_kind_of(::Array, @team_model.chassis)
    assert_equal(0, @team_model.chassis.size)

    assert_kind_of(::Array, @team_model)
    assert_equal(0, @team_model.size)
  end

  def check_that_all_attributes_value_are_correctly_synced_from_filled_form
    @team.sync_to_model(@team_model)

    assert_equal(@team.name, @team_model.team_name)
    assert_equal(@team.year, @team_model.year)

    assert_kind_of(::Array, @team_model.cars)
    assert_equal(2, @team_model.cars.size)

    assert_equal(@team.cars[0].code, @team_model.cars[0].code)
    assert_equal(@team.cars[0].driver, @team_model.cars[0].driver)
    assert_equal(@team.cars[0].engine.power, @team_model.cars[0].engine.power)
    assert_nil(@team_model.cars[0].engine.volume)

    assert_equal(@team.cars[1].code, @team_model.cars[1].code)
    assert_equal(@team.cars[1].driver, @team_model.cars[1].driver)
    assert_equal(@team.cars[1].engine.power, @team_model.cars[1].engine.power)
    assert_equal(@team.cars[1].engine.volume, @team_model.cars[1].engine.volume)

    assert_kind_of(::Array, @team_model.finance[:sponsors])
    assert_equal(2, @team_model.finance[:sponsors].size)

    assert_equal(@team.sponsors[0].title, @team_model.finance[:sponsors][0].title)
    assert_equal(@team.sponsors[0].money, @team_model.finance[:sponsors][0].money)

    assert_equal(@team.sponsors[1].title, @team_model.finance[:sponsors][1].title)
    assert_equal(@team.sponsors[1].money, @team_model.finance[:sponsors][1].money)

    assert_kind_of(::Array, @team_model.chassis)
    assert_equal(2, @team_model.chassis.size)

    assert_equal(@team.chassis[0].id, @team_model.chassis[0][:id])
    assert_equal(@team.chassis[0].suspension.front, @team_model.chassis[0][:suspension].front)
    assert_equal(@team.chassis[0].suspension.rear, @team_model.chassis[0][:suspension].rear)
    assert_equal(@team.chassis[0].brakes, @team_model.chassis[0][:brakes])

    assert_equal(@team.chassis[1].id, @team_model.chassis[1][:id])
    assert_equal(@team.chassis[1].suspension.front, @team_model.chassis[1][:suspension].front)
    assert_equal(@team.chassis[1].suspension.rear, @team_model.chassis[1][:suspension].rear)
    assert_equal(@team.chassis[1].brakes, @team_model.chassis[1][:brakes])

    assert_kind_of(::Array, @team_model)
    assert_equal(1, @team_model.size)

    assert_equal(@team.colours[0].name, @team_model[0].name)
    assert_equal(@team.colours[0].rgb, @team_model[0].rgb)
  end
end