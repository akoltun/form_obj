require "test_helper"

class FormDuplicateAttributeTest < Minitest::Test
  class Suspension < FormObj::Form
    attribute :front, default: 'dependant'
    attribute :front

    attribute :fantastic, default: :flying
    attribute :fantastic, default: :jumping

    attribute :rear
    attribute :rear, default: 'de Dion'
  end

  class OldChassis < FormObj::Form
    attribute :old_suspension, class: Suspension
    attribute :old_brakes
  end

  class Chassis < FormObj::Form
    attribute :suspension, class: Suspension
    attribute :brakes
  end

  class Colour < FormObj::Form
    attribute :name
    attribute :rgb
  end

  class Team < FormObj::Form
    attribute :full_name, default: 'Scuderia Ferrari'
    attribute :full_name

    attribute :name, default: 'Ferrari'
    attribute :name, default: 'McLaren'

    attribute :year
    attribute :year, default: 1950

    attribute :cars, array: true do
      attribute :wheel
    end
    attribute :cars, array: true do
      attribute :code
      attribute :driver

      attribute :engine do
        attribute :old_power
        attribute :volume, default: 5.0
      end
      attribute :engine do
        attribute :power
        attribute :volume
      end

      attribute :chassis, class: 'FormDuplicateAttributeTest::OldChassis'
      attribute :chassis, class: 'FormDuplicateAttributeTest::Chassis'
    end

    attribute :colours, class: Colour, array: true
    attribute :colours
  end

  def test_that_team_has_only_one_attribute_of_each_name
    assert_equal(%i{full_name name year cars colours}, Team.attributes)
  end

  def test_that_team_attributes_apply_only_last_parameters
    team = Team.new

    assert_nil(team.full_name)
    assert_equal('McLaren', team.name)
    assert_equal(1950, team.year)
    assert_nil(team.colours)
  end

  def test_that_car_has_only_one_attribute_of_each_name
    assert_equal(%i{code driver engine chassis}, Team.new.cars.create.class.attributes)
  end

  def test_that_car_attributes_apply_only_last_parameters
    car = Team.new.cars.create

    assert_equal(%i{power volume}, car.engine.class.attributes)
    assert_nil(car.engine.volume)

    assert_kind_of(Chassis, car.chassis)
  end

  def test_that_suspension_has_only_one_attribute_of_each_name
    assert_equal(%i{front fantastic rear}, Team.new.cars.create.chassis.suspension.class.attributes)
  end

  def test_that_suspension_attributes_apply_only_last_parameters
    suspension = Team.new.cars.create.chassis.suspension

    assert_nil(suspension.front)
    assert_equal(:jumping, suspension.fantastic)
    assert_equal('de Dion', suspension.rear)
  end
end
