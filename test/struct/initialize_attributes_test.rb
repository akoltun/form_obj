require "test_helper"

class StructInitializeAttributesTest < Minitest::Test
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
      attribute :code, primary_key: true
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
      attribute :chassis, class: 'StructInitializeAttributesTest::Chassis'
    end
    attribute :colours, class: Colour, array: true, primary_key: :name
  end

  def test_that_all_attributes_are_correctly_initialized
    team = Team.new(
        name: 'McLaren',
        'name' => 'Ferrari',
        year: 1950,
        cars: [{
                   code: '340 F1',
                   'driver' => 'Ascari',
                   engine: {
                       power: 335,
                       volume: 4.1
                   },
                   chassis: {
                       suspension: {
                           front: 'independent',
                           rear: 'de Dion',
                       },
                       brakes: :drum,
                   }
               }, {
                   code: '275 F1',
                   'driver' => 'Ascari',
                   driver: 'Villoresi',
                   engine: {
                       power: 300,
                       volume: 3.3
                   },
                   chassis: {
                       suspension: {
                           front: 'dependent',
                           rear: 'de Lion',
                       },
                       brakes: :disc,
                   }
               }],
        colours: [{
                      name: :red,
                      rgb: nil,
                      'rgb' => 0xFF0000,
                  }, {
                      name: :white,
                      'rgb' => nil,
                      rgb: 0xFFFFFF,
                  }]
    )

    assert_equal('Ferrari', team.name)
    assert_equal(1950,      team.year)

    assert_equal(2, team.cars.size)

    assert_equal('340 F1',      team.cars[0].code)
    assert_equal('Ascari',      team.cars[0].driver)
    assert_equal(335,           team.cars[0].engine.power)
    assert_equal(4.1,           team.cars[0].engine.volume)
    assert_equal('independent', team.cars[0].chassis.suspension.front)
    assert_equal('de Dion',     team.cars[0].chassis.suspension.rear)
    assert_equal(:drum,         team.cars[0].chassis.brakes)

    assert_equal('275 F1',    team.cars[1].code)
    assert_equal('Villoresi', team.cars[1].driver)
    assert_equal(300,         team.cars[1].engine.power)
    assert_equal(3.3,         team.cars[1].engine.volume)
    assert_equal('dependent', team.cars[1].chassis.suspension.front)
    assert_equal('de Lion',   team.cars[1].chassis.suspension.rear)
    assert_equal(:disc,       team.cars[1].chassis.brakes)

    assert_equal(2, team.colours.size)

    assert_equal(:red,      team.colours[0].name)
    assert_equal(0xFF0000,  team.colours[0].rgb)

    assert_equal(:white,    team.colours[1].name)
    assert_equal(0xFFFFFF,  team.colours[1].rgb)
  end

  def test_that_correctly_initialize_even_not_all_attributes
    team = Team.new(
        name: 'Ferrari',
        cars: [{
                   chassis: {
                       brakes: :drum,
                   }
               }],
    )

    assert_equal('Ferrari', team.name)
    assert_nil(team.year)

    assert_equal(1, team.cars.size)

    assert_nil(team.cars[0].code)
    assert_nil(team.cars[0].driver)
    assert_nil(team.cars[0].engine.power)
    assert_nil(team.cars[0].engine.volume)
    assert_nil(team.cars[0].chassis.suspension.front)
    assert_nil(team.cars[0].chassis.suspension.rear)
    assert_equal(:drum, team.cars[0].chassis.brakes)

    assert_equal(0, team.colours.size)
  end

  def test_that_error_is_raised_when_try_to_initialize_non_existent_attribute
    assert_raises(FormObj::UnknownAttributeError) { Team.new(a: 1) }

    assert_raises(FormObj::UnknownAttributeError) { Team.new(cars: [{a: 1}]) }

    assert_raises(FormObj::UnknownAttributeError) { Team.new(cars: [{chassis: {a: 1}}]) }
  end

  def test_that_error_is_raised_when_try_to_initialize_non_existent_attribute_with_parameter_raise_if_not_found_equal_to_true
    assert_raises(FormObj::UnknownAttributeError) { Team.new({a: 1}, raise_if_not_found: true) }

    assert_raises(FormObj::UnknownAttributeError) { Team.new({cars: [{a: 1}]}, raise_if_not_found: true) }

    assert_raises(FormObj::UnknownAttributeError) { Team.new({cars: [{chassis: {a: 1}}]}, raise_if_not_found: true) }
  end

  def test_that_non_existent_attribute_is_ignored_when_try_to_initialize_it_with_parameter_raise_if_not_found_equal_to_false
    team = Team.new({
                        name: 'Ferrari',
                        a: 1,
                        cars: [{
                                   b: 2,
                                   chassis: {
                                       brakes: :drum,
                                       c: 3
                                   }
                               }],
                    }, raise_if_not_found: false)

    assert_equal('Ferrari', team.name)
    assert_nil(team.year)

    assert_equal(1, team.cars.size)

    assert_nil(team.cars[0].code)
    assert_nil(team.cars[0].driver)
    assert_nil(team.cars[0].engine.power)
    assert_nil(team.cars[0].engine.volume)
    assert_nil(team.cars[0].chassis.suspension.front)
    assert_nil(team.cars[0].chassis.suspension.rear)
    assert_equal(:drum, team.cars[0].chassis.brakes)

    assert_equal(0, team.colours.size)

    assert_raises(NoMethodError) { team.a }
    assert_raises(NoMethodError) { team.cars[0].b }
    assert_raises(NoMethodError) { team.cars[0].chassis.c }
  end
end
