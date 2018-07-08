require "test_helper"

Suspension = Struct.new(:front, :rear)

module ModelMarkableForDestruction
  def mark_for_destruction
    @marked_for_destruction = true
  end

  def marked_for_destruction?
    @marked_for_destruction
  end
end

class ModelMapperSyncToModelTest < Minitest::Test
  class ArrayWithWhere < Array
    def where(condition)
      key = condition.keys.first
      values = condition.values.first

      select { |item| values.include?(item.is_a?(::Hash) ? item[key] : item.send(key)) }
    end
  end

  EngineModel = Struct.new(:power, :volume, :secret) { include ModelMarkableForDestruction }
  CarModel = Struct.new(:code, :driver, :engine, :secret) { include ModelMarkableForDestruction }
  SponsorModel = Struct.new(:title, :money, :secret) { include ModelMarkableForDestruction }
  ColourModel = Struct.new(:name, :rgb, :secret) { include ModelMarkableForDestruction }
  DriversChampionshipModel = Struct.new(:driver, :year, :secret) { include ModelMarkableForDestruction }

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
    @team_model.cars = ArrayWithWhere[
        CarModel.new('340 F1', 'Ascari', EngineModel.new(335, 3.0), 1),
        CarModel.new('275 F1', 'Villoresi', EngineModel.new(300, 3.3), 2),
        CarModel.new('375 F1', 'Sommer', EngineModel.new(400, 4.5), 3),
    ]
    @team_model.finance = {
        sponsors: ArrayWithWhere[
            SponsorModel.new('Shell', 1000000, 1),
            SponsorModel.new('Dunlop', 200000, 2),
            SponsorModel.new('Pirelli', 500000, 3),
        ]
    }
    @team_model.chassis = [
        { id: 1, suspension: Suspension.new('old', 'very old'), brakes: :hand },
        { id: 2, suspension: Suspension.new('new', 'very new'), brakes: :leg },
        { id: 3, suspension: Suspension.new('crazy', 'very crazy'), brakes: :body },
    ]
    @team_model.drivers_championships = [
        DriversChampionshipModel.new('Ascari', 1952),
        DriversChampionshipModel.new('Hawthorn', 1958),
        DriversChampionshipModel.new('Lauda', 1977),
    ]

    @team_model.push(ColourModel.new('red', 0xFF0000, 1), ColourModel.new('green', 0x00FF00, 2), ColourModel.new('blue', 0x0000FF, 3))
  end

  def fill_in_form
    @team.name = 'McLaren'
    @team.year = 1966

    car = @team.cars.create
    car.code = '340 F1'
    car.driver = 'Bruce McLaren'
    car.engine.power = 310
    car.engine.volume = nil

    car = @team.cars.create
    car.code = '375 F1'
    car.mark_for_destruction

    car = @team.cars.create
    car.code = 'M7A'
    car.driver = 'Denis Hulme'
    car.engine.power = 415
    car.engine.volume = 4.3

    car = @team.cars.create
    car.code = 'M23'
    car.driver = 'Revson'
    car.engine.power = 490
    car.engine.volume = 2.9
    car.mark_for_destruction

    sponsor = @team.sponsors.create
    sponsor.title = 'Shell'
    sponsor.money = 250

    sponsor = @team.sponsors.create
    sponsor.title = 'Total'
    sponsor.money = 3000

    sponsor = @team.sponsors.create
    sponsor.title = 'Dunlop'
    sponsor.money = 0
    sponsor.mark_for_destruction

    sponsor = @team.sponsors.create
    sponsor.title = 'AMD'
    sponsor.money = 1234567
    sponsor.mark_for_destruction

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
    chassis.mark_for_destruction

    chassis = @team.chassis.create
    chassis.id = 4
    chassis.suspension.front = 'temp1'
    chassis.suspension.rear = 'temp2'
    chassis.brakes = :hydro
    chassis.mark_for_destruction

    chassis = @team.chassis.create
    chassis.id = 5
    chassis.suspension.front = 'swing axle'
    chassis.suspension.rear = 'McPherson'
    chassis.brakes = :electro

    colour = @team.colours.create
    colour.name = 'green'
    colour.rgb = 0x00FE00

    colour = @team.colours.create
    colour.name = 'blue'
    colour.rgb = 0x0000FE
    colour.mark_for_destruction

    colour = @team.colours.create
    colour.name = 'white'
    colour.rgb = 0xFFFFFF

    colour = @team.colours.create
    colour.name = 'black'
    colour.rgb = 0x000000
    colour.mark_for_destruction

    drivers_championship = @team.drivers_championships.create
    drivers_championship.driver = 'Ascari'
    drivers_championship.year = 1964

    drivers_championship = @team.drivers_championships.create
    drivers_championship.driver = 'Rindt'
    drivers_championship.year = 1970

    drivers_championship = @team.drivers_championships.create
    drivers_championship.driver = 'Hawthorn'
    drivers_championship.mark_for_destruction

    constructors_championship = @team.constructors_championships.create
    constructors_championship.year = 1961

    constructors_championship = @team.constructors_championships.create
    constructors_championship.year = 1964
  end

  def test_that_sync_to_model_returns_form_itself
    assert_same(@team, @team.sync_to_model(@team_model))
  end

  def test_that_all_attributes_value_are_correctly_synced_from_empty_form_into_empty_model
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

    assert_nil(@team_model.drivers_championships)
  end

  def test_that_all_attributes_value_are_correctly_synced_from_empty_form_into_filled_model
    fill_in_model

    check_that_not_synced_attributes_keep_their_values

    @team.sync_to_model(@team_model)

    assert_nil(@team_model.team_name)
    assert_nil(@team_model.year)

    assert_kind_of(::Array, @team_model.cars)
    assert_equal(['275 F1', '340 F1', '375 F1'], @team_model.cars.map(&:code).sort)

    car = @team_model.cars.find { |car| car.code == '275 F1' }
    assert_equal('Villoresi', car.driver)
    assert_equal(300, car.engine.power)
    assert_equal(3.3, car.engine.volume)
    assert_equal(2, car.secret)
    refute(car.marked_for_destruction?)

    car = @team_model.cars.find { |car| car.code == '340 F1' }
    assert_equal('Ascari', car.driver)
    assert_equal(335, car.engine.power)
    assert_equal(3.0, car.engine.volume)
    assert_equal(1, car.secret)
    refute(car.marked_for_destruction?)

    car = @team_model.cars.find { |car| car.code == '375 F1' }
    assert_equal('Sommer', car.driver)
    assert_equal(400, car.engine.power)
    assert_equal(4.5, car.engine.volume)
    assert_equal(3, car.secret)
    refute(car.marked_for_destruction?)

    assert_kind_of(::Array, @team_model.finance[:sponsors])
    assert_equal(%w{Dunlop Pirelli Shell}, @team_model.finance[:sponsors].map(&:title).sort)

    sponsor = @team_model.finance[:sponsors].find { |sponsor| sponsor.title == 'Dunlop' }
    assert_equal(200000, sponsor.money)
    assert_equal(2, sponsor.secret)
    refute(sponsor.marked_for_destruction?)

    sponsor = @team_model.finance[:sponsors].find { |sponsor| sponsor.title == 'Pirelli' }
    assert_equal(500000, sponsor.money)
    assert_equal(3, sponsor.secret)
    refute(sponsor.marked_for_destruction?)

    sponsor = @team_model.finance[:sponsors].find { |sponsor| sponsor.title == 'Shell' }
    assert_equal(1000000, sponsor.money)
    assert_equal(1, sponsor.secret)
    refute(sponsor.marked_for_destruction?)

    assert_kind_of(::Array, @team_model.chassis)
    assert_equal([1, 2, 3], @team_model.chassis.map { |chassis| chassis[:id] }.sort)

    chassis = @team_model.chassis.find { |chassis| chassis[:id] == 1 }
    assert_equal('old', chassis[:suspension].front)
    assert_equal('very old', chassis[:suspension].rear)
    assert_equal(:hand, chassis[:brakes])

    chassis = @team_model.chassis.find { |chassis| chassis[:id] == 2 }
    assert_equal('new', chassis[:suspension].front)
    assert_equal('very new', chassis[:suspension].rear)
    assert_equal(:leg, chassis[:brakes])

    chassis = @team_model.chassis.find { |chassis| chassis[:id] == 3 }
    assert_equal('crazy', chassis[:suspension].front)
    assert_equal('very crazy', chassis[:suspension].rear)
    assert_equal(:body, chassis[:brakes])

    assert_kind_of(::Array, @team_model)
    assert_equal(%w{blue green red}, @team_model.map(&:name).sort)

    colour = @team_model.find { |colour| colour.name == 'blue' }
    assert_equal(0x0000FF, colour.rgb)
    assert_equal(3, colour.secret)

    colour = @team_model.find { |colour| colour.name == 'green' }
    assert_equal(0x00FF00, colour.rgb)
    assert_equal(2, colour.secret)

    colour = @team_model.find { |colour| colour.name == 'red' }
    assert_equal(0xFF0000, colour.rgb)
    assert_equal(1, colour.secret)
  end

  def test_that_all_attributes_value_are_correctly_synced_from_filled_form_into_empty_model
    fill_in_form

    @team.sync_to_model(@team_model)

    assert_equal('McLaren', @team_model.team_name)
    assert_equal(1966, @team_model.year)

    assert_kind_of(::Array, @team_model.cars)
    assert_equal(['340 F1', 'M7A'], @team_model.cars.map(&:code).sort)

    car = @team_model.cars.find { |car| car.code == '340 F1' }
    assert_equal('Bruce McLaren', car.driver)
    assert_equal(310, car.engine.power)
    assert_nil(car.engine.volume)
    assert_nil(car.secret)
    refute(car.marked_for_destruction?)

    car = @team_model.cars.find { |car| car.code == 'M7A' }
    assert_equal('Denis Hulme', car.driver)
    assert_equal(415, car.engine.power)
    assert_equal(4.3, car.engine.volume)
    assert_nil(car.secret)
    refute(car.marked_for_destruction?)

    assert_kind_of(::Array, @team_model.finance[:sponsors])
    assert_equal(%w{Shell Total}, @team_model.finance[:sponsors].map(&:title).sort)

    sponsor = @team_model.finance[:sponsors].find { |sponsor| sponsor.title == 'Shell' }
    assert_equal(250, sponsor.money)
    refute(sponsor.marked_for_destruction?)
    assert_nil(sponsor.secret)

    sponsor = @team_model.finance[:sponsors].find { |sponsor| sponsor.title == 'Total' }
    assert_equal(3000, sponsor.money)
    assert_nil(sponsor.secret)
    refute(sponsor.marked_for_destruction?)

    assert_kind_of(::Array, @team_model.chassis)
    assert_equal([1, 5], @team_model.chassis.map { |chassis| chassis[:id] }.sort)

    chassis = @team_model.chassis.find { |chassis| chassis[:id] == 1 }
    assert_equal('independent', chassis[:suspension].front)
    assert_equal('de Dion', chassis[:suspension].rear)
    assert_equal(:drum, chassis[:brakes])

    chassis = @team_model.chassis.find { |chassis| chassis[:id] == 5 }
    assert_equal('swing axle', chassis[:suspension].front)
    assert_equal('McPherson', chassis[:suspension].rear)
    assert_equal(:electro, chassis[:brakes])

    assert_kind_of(::Array, @team_model)
    assert_equal(%w{green white}, @team_model.map(&:name).sort)

    colour = @team_model.find { |colour| colour.name == 'green' }
    assert_equal(0x00FE00, colour.rgb)
    assert_nil(colour.secret)

    colour = @team_model.find { |colour| colour.name == 'white' }
    assert_equal(0xFFFFFF, colour.rgb)
    assert_nil(colour.secret)

    assert_nil(@team_model.drivers_championships)
  end

  def test_that_all_attributes_value_are_correctly_synced_from_filled_form_into_filled_model
    fill_in_form
    fill_in_model

    check_that_not_synced_attributes_keep_their_values

    @team.sync_to_model(@team_model)

    assert_equal('McLaren', @team_model.team_name)
    assert_equal(1966, @team_model.year)

    assert_kind_of(::Array, @team_model.cars)
    assert_equal(['275 F1', '340 F1', '375 F1', 'M7A'] , @team_model.cars.map(&:code).sort)

    car = @team_model.cars.find { |car| car.code == '275 F1' }
    assert_equal('Villoresi', car.driver)
    assert_equal(300, car.engine.power)
    assert_equal(3.3, car.engine.volume)
    assert_equal(2, car.secret)
    refute(car.marked_for_destruction?)

    car = @team_model.cars.find { |car| car.code == '340 F1' }
    assert_equal('Bruce McLaren', car.driver)
    assert_equal(310, car.engine.power)
    assert_nil(car.engine.volume)
    assert_equal(1, car.secret)
    refute(car.marked_for_destruction?)

    car = @team_model.cars.find { |car| car.code == '375 F1' }
    assert_equal('Sommer', car.driver)
    assert_equal(400, car.engine.power)
    assert_equal(4.5, car.engine.volume)
    assert_equal(3, car.secret)
    assert(car.marked_for_destruction?)

    car = @team_model.cars.find { |car| car.code == 'M7A' }
    assert_equal('Denis Hulme', car.driver)
    assert_equal(415, car.engine.power)
    assert_equal(4.3, car.engine.volume)
    assert_nil(car.secret)
    refute(car.marked_for_destruction?)

    assert_kind_of(::Array, @team_model.finance[:sponsors])
    assert_equal(%w{Dunlop Pirelli Shell Total}, @team_model.finance[:sponsors].map(&:title).sort)

    sponsor = @team_model.finance[:sponsors].find { |sponsor| sponsor.title == 'Dunlop' }
    assert_equal(200000, sponsor.money)
    assert_equal(2, sponsor.secret)
    assert(sponsor.marked_for_destruction?)

    sponsor = @team_model.finance[:sponsors].find { |sponsor| sponsor.title == 'Pirelli' }
    assert_equal(500000, sponsor.money)
    assert_equal(3, sponsor.secret)
    refute(sponsor.marked_for_destruction?)

    sponsor = @team_model.finance[:sponsors].find { |sponsor| sponsor.title == 'Shell' }
    assert_equal(250, sponsor.money)
    refute(sponsor.marked_for_destruction?)
    assert_equal(1, sponsor.secret)

    sponsor = @team_model.finance[:sponsors].find { |sponsor| sponsor.title == 'Total' }
    assert_equal(3000, sponsor.money)
    assert_nil(sponsor.secret)
    refute(sponsor.marked_for_destruction?)

    assert_kind_of(::Array, @team_model.chassis)
    assert_equal([1, 2, 5], @team_model.chassis.map { |chassis| chassis[:id] }.sort)

    chassis = @team_model.chassis.find { |chassis| chassis[:id] == 1 }
    assert_equal('independent', chassis[:suspension].front)
    assert_equal('de Dion', chassis[:suspension].rear)
    assert_equal(:drum, chassis[:brakes])

    chassis = @team_model.chassis.find { |chassis| chassis[:id] == 2 }
    assert_equal('new', chassis[:suspension].front)
    assert_equal('very new', chassis[:suspension].rear)
    assert_equal(:leg, chassis[:brakes])

    chassis = @team_model.chassis.find { |chassis| chassis[:id] == 5 }
    assert_equal('swing axle', chassis[:suspension].front)
    assert_equal('McPherson', chassis[:suspension].rear)
    assert_equal(:electro, chassis[:brakes])

    assert_kind_of(::Array, @team_model)
    assert_equal(%w{green red white}, @team_model.map(&:name).sort)

    colour = @team_model.find { |colour| colour.name == 'green' }
    assert_equal(0x00FE00, colour.rgb)
    assert_equal(2, colour.secret)

    colour = @team_model.find { |colour| colour.name == 'red' }
    assert_equal(0xFF0000, colour.rgb)
    assert_equal(1, colour.secret)

    colour = @team_model.find { |colour| colour.name == 'white' }
    assert_equal(0xFFFFFF, colour.rgb)
    assert_nil(colour.secret)
  end

  def check_that_not_synced_attributes_are_still_empty
    assert_nil(@team_model.drivers_championships)
  end

  def check_that_not_synced_attributes_keep_their_values
    assert_kind_of(::Array, @team_model.drivers_championships)
    assert_equal(3, @team_model.drivers_championships.size)

    assert_equal('Ascari', @team_model.drivers_championships[0].driver)
    assert_equal(1952, @team_model.drivers_championships[0].year)

    assert_equal('Hawthorn', @team_model.drivers_championships[1].driver)
    assert_equal(1958, @team_model.drivers_championships[1].year)

    assert_equal('Lauda', @team_model.drivers_championships[2].driver)
    assert_equal(1977, @team_model.drivers_championships[2].year)
  end
end