require "test_helper"

class AssignValuesTest < Minitest::Test
  class Suspension < FormObj::Struct
    attribute :front
    attribute :rear
  end
  class Chassis < FormObj::Struct
    attribute :suspension, class: Suspension
    attribute :brakes
  end
  class Colour < FormObj::Struct
    attribute :name
    attribute :rgb
  end
  class Team < FormObj::Struct
    attribute :name
    attribute :year
    attribute :cars, array: true do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
      attribute :chassis, class: 'AssignValuesTest::Chassis'
    end
    attribute :colours, class: Colour, array: true
  end

  def setup
    @team = Team.new

    @team.name = 'Ferrari'
    @team.year = 1950

    car = @team.cars.create
    car.code = '340 F1'
    car.driver = 'Ascari'
    car.engine.power = 335
    car.engine.volume = 4.1
    car.chassis.suspension.front = 'independent'
    car.chassis.suspension.rear = 'de Dion'
    car.chassis.brakes = :drum

    suspension = Suspension.new
    suspension.front = 'dependent'
    suspension.rear = 'de Lion'

    chassis = Chassis.new
    chassis.suspension = suspension
    chassis.brakes = :disc

    car = @team.cars.create
    car.code = '275 F1'
    car.driver = 'Villoresi'
    car.engine.power = 300
    car.engine.volume = 3.3
    car.chassis = chassis

    colour = @team.colours.create
    colour.name = :red
    colour.rgb = 0xFF0000
    
    colour = Colour.new
    colour.name = :white
    colour.rgb = 0xFFFFFF
    @team.colours << colour
  end

  def test_that_all_values_are_correctly_assigned
    assert_equal('Ferrari', @team.name)
    assert_equal(1950,      @team.year)

    assert_equal(2, @team.cars.size)

    assert_equal('340 F1',      @team.cars[0].code)
    assert_equal('Ascari',      @team.cars[0].driver)
    assert_equal(335,           @team.cars[0].engine.power)
    assert_equal(4.1,           @team.cars[0].engine.volume)
    assert_equal('independent', @team.cars[0].chassis.suspension.front)
    assert_equal('de Dion',     @team.cars[0].chassis.suspension.rear)
    assert_equal(:drum,         @team.cars[0].chassis.brakes)

    assert_equal('275 F1',    @team.cars[1].code)
    assert_equal('Villoresi', @team.cars[1].driver)
    assert_equal(300,         @team.cars[1].engine.power)
    assert_equal(3.3,         @team.cars[1].engine.volume)
    assert_equal('dependent', @team.cars[1].chassis.suspension.front)
    assert_equal('de Lion',   @team.cars[1].chassis.suspension.rear)
    assert_equal(:disc,       @team.cars[1].chassis.brakes)

    assert_equal(2, @team.colours.size)
    
    assert_equal(:red,      @team.colours[0].name)
    assert_equal(0xFF0000,  @team.colours[0].rgb)

    assert_equal(:white,    @team.colours[1].name)
    assert_equal(0xFFFFFF,  @team.colours[1].rgb)
  end

  def test_that_non_existent_attribute_raises_error
    assert_raises(NoMethodError) { @team.non_existent_attribute }

    assert_raises(NoMethodError) { @team.cars[0].non_existent_attribute }
    assert_raises(NoMethodError) { @team.cars[0].engine.non_existent_attribute }

    assert_raises(NoMethodError) { @team.cars[1].non_existent_attribute }
    assert_raises(NoMethodError) { @team.cars[1].engine.non_existent_attribute }

    assert_raises(NoMethodError) { @team.colours[0].non_existent_attribute }
    assert_raises(NoMethodError) { @team.colours[0].engine.non_existent_attribute }

    assert_raises(NoMethodError) { @team.colours[1].non_existent_attribute }
    assert_raises(NoMethodError) { @team.colours[1].engine.non_existent_attribute }
  end
end
