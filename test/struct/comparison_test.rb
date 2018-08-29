require "test_helper"

class StructComparisonTest < Minitest::Test
  class Suspension < FormObj::Struct
    attribute :front
    attribute :rear
  end
  class SuspensionWithLessAttributes < FormObj::Struct
    attribute :front
  end
  class Chassis < FormObj::Struct
    attribute :suspension, class: Suspension
    attribute :brakes
  end
  class ChassisWithLessAttributes < FormObj::Struct
    attribute :suspension, class: SuspensionWithLessAttributes
    attribute :brakes
  end
  class Colour < FormObj::Struct
    attribute :name
    attribute :rgb
  end
  class Team < FormObj::Struct
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
      attribute :chassis, class: 'StructComparisonTest::Chassis'
    end
    attribute :colours, class: Colour, array: true, primary_key: :name
  end
  class TeamWithLessAttributes < FormObj::Struct
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
      attribute :chassis, class: ChassisWithLessAttributes
    end
    attribute :colours, class: Colour, array: true, primary_key: :name
  end
  class TeamWithDifferentAttributes < FormObj::Struct
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :horse_power
        attribute :volume
      end
      attribute :chassis, class: Chassis
    end
    attribute :colours, class: Colour, array: true, primary_key: :name
  end
  class TeamInheritor < Team
    attribute :founder
  end
  TeamAnotherClass = Struct.new(:name, :year, :cars, :colours)
  CarAnotherClass = Struct.new(:code, :driver, :engine, :chassis)
  EngineAnotherClass = Struct.new(:power, :volume)
  ChassisAnotherClass = Struct.new(:suspension, :brakes)
  SuspensionAnotherClass = Struct.new(:front, :rear)
  ColourAnotherClass = Struct.new(:name, :rgb)

  def setup
    @team = initialize_team(Team.new)
    @team_same_instance = @team
    @team_same_class_same_attributes = initialize_team(Team.new)
    @team_less_attributes = initialize_team(TeamWithLessAttributes.new)
    @team_different_attributes = initialize_team(TeamWithDifferentAttributes.new)
    @team_inherited_class_more_attributes = initialize_team(TeamInheritor.new)

    @team_another_class_same_attributes = TeamAnotherClass.new(
        @team.name, 
        @team.year,
        [
            CarAnotherClass.new(
                @team.cars[0].code, 
                @team.cars[0].driver, 
                EngineAnotherClass.new(
                    @team.cars[0].engine.power, 
                    @team.cars[0].engine.volume
                ), 
                ChassisAnotherClass.new(
                    SuspensionAnotherClass.new(
                        @team.cars[0].chassis.suspension.front,
                        @team.cars[0].chassis.suspension.rear,
                    ),
                    @team.cars[0].chassis.brakes
                )
            ),
            CarAnotherClass.new(
                @team.cars[1].code, 
                @team.cars[1].driver, 
                EngineAnotherClass.new(
                    @team.cars[1].engine.power, 
                    @team.cars[1].engine.volume
                ), 
                ChassisAnotherClass.new(
                    SuspensionAnotherClass.new(
                        @team.cars[1].chassis.suspension.front,
                        @team.cars[1].chassis.suspension.rear,
                    ),
                    @team.cars[1].chassis.brakes
                )
            ),
        ], 
        [
            ColourAnotherClass.new(@team.colours[0].name, @team.colours[0].rgb),
            ColourAnotherClass.new(@team.colours[1].name, @team.colours[1].rgb),
        ])
  end
  
  def initialize_team(team)
    team.name = 'Ferrari'
    team.year = 1950

    car = team.cars.create
    car.code = '340 F1'
    car.driver = 'Ascari'
    car.engine.power = 335 if car.engine.respond_to? :power=
    car.engine.horse_power = 335 if car.engine.respond_to? :horse_power=
    car.engine.volume = 4.1
    car.chassis.suspension.front = 'independent'
    car.chassis.suspension.rear = 'de Dion' if car.chassis.suspension.respond_to? :rear=
    car.chassis.brakes = :drum

    suspension = car.chassis.suspension.class.new
    suspension.front = 'dependent'
    suspension.rear = 'de Lion' if suspension.respond_to? :rear=

    chassis = car.chassis.class.new
    chassis.suspension = suspension
    chassis.brakes = :disc

    car = team.cars.create
    car.code = '275 F1'
    car.driver = 'Villoresi'
    car.engine.power = 300 if car.engine.respond_to? :power=
    car.engine.horse_power = 300 if car.engine.respond_to? :horse_power=
    car.engine.volume = 3.3
    car.chassis = chassis

    colour = team.colours.create
    colour.name = :red
    colour.rgb = 0xFF0000

    colour = Colour.new
    colour.name = :white
    colour.rgb = 0xFFFFFF
    team.colours << colour
    
    team
  end

  def test_eql
    assert(@team.eql? @team)

    assert(@team.eql? @team_same_instance)
    
    assert(@team.eql? @team_same_class_same_attributes)
    assert(@team_same_class_same_attributes.eql? @team)
    
    refute(@team.eql? @team_less_attributes)
    refute(@team_less_attributes.eql? @team)
    
    refute(@team.eql? @team_different_attributes)
    refute(@team_different_attributes.eql? @team)
    
    assert(@team.eql? @team_inherited_class_more_attributes)
    refute(@team_inherited_class_more_attributes.eql? @team)
    
    refute(@team.eql? @team_another_class_same_attributes)

    refute(@team.eql? 1)
  end

  def test_double_equal_sign
    assert(@team == @team)

    assert(@team == @team_same_instance)

    assert(@team == @team_same_class_same_attributes)
    assert(@team_same_class_same_attributes == @team)

    refute(@team == @team_less_attributes)
    assert(@team_less_attributes == @team)

    refute(@team == @team_different_attributes)
    refute(@team_different_attributes == @team)

    assert(@team == @team_inherited_class_more_attributes)
    refute(@team_inherited_class_more_attributes == @team)

    assert(@team == @team_another_class_same_attributes)

    refute(@team == 1)
  end

  def test_triple_equal_sign
    assert(@team === @team)

    assert(@team === @team_same_instance)

    assert(@team === @team_same_class_same_attributes)
    assert(@team_same_class_same_attributes === @team)

    refute(@team === @team_less_attributes)
    assert(@team_less_attributes === @team)

    refute(@team === @team_different_attributes)
    refute(@team_different_attributes === @team)

    assert(@team === @team_inherited_class_more_attributes)
    refute(@team_inherited_class_more_attributes === @team)

    assert(@team === @team_another_class_same_attributes)

    refute(@team === 1)
  end

  def test_equality_when_root_attributes_differs
    @team_same_class_same_attributes.name = 'McLaren'

    refute(@team.eql? @team_same_class_same_attributes)
    refute(@team == @team_same_class_same_attributes)
    refute(@team === @team_same_class_same_attributes)
  end

  def test_equality_when_attributes_in_array_differs
    @team_same_class_same_attributes.cars[0].code = '345 F1'

    refute(@team.eql? @team_same_class_same_attributes)
    refute(@team == @team_same_class_same_attributes)
    refute(@team === @team_same_class_same_attributes)
  end

  def test_equality_when_attributes_in_array_defined_by_class_differs
    @team_same_class_same_attributes.colours[0].name = :blue

    refute(@team.eql? @team_same_class_same_attributes)
    refute(@team == @team_same_class_same_attributes)
    refute(@team === @team_same_class_same_attributes)
  end

  def test_equality_when_nested_attributes_differs
    @team_same_class_same_attributes.cars[0].engine.power = 410

    refute(@team.eql? @team_same_class_same_attributes)
    refute(@team == @team_same_class_same_attributes)
    refute(@team === @team_same_class_same_attributes)
  end

  def test_equality_when_nested_attributes_defined_by_class_differs
    @team_same_class_same_attributes.cars[0].chassis.suspension.front = 'revolution'

    refute(@team.eql? @team_same_class_same_attributes)
    refute(@team == @team_same_class_same_attributes)
    refute(@team === @team_same_class_same_attributes)
  end
end
