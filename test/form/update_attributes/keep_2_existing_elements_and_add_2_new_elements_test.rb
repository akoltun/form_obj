require "test_helper"

class FormUpdateAttributesAndKeepTwoExistingElementsAndAddTwoNewElementsTest < Minitest::Test
  class Suspension < FormObj::Form
    attribute :front
    attribute :rear
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
    attribute :name
    attribute :year
    attribute :cars, array: true do
      attribute :code, primary_key: true
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
      attribute :chassis, class: 'FormUpdateAttributesAndKeepTwoExistingElementsAndAddTwoNewElementsTest::Chassis'
    end
    attribute :colours, class: Colour, array: true, primary_key: :name
  end

  def test_that_all_attributes_are_correctly_updated
    team = Team.new(
        name: 'McLaren',
        year: 1966,
        cars: [{
                   code: 'M2B',
                   driver: 'Bruce McLaren',
                   engine: {
                       power: 363,
                       volume: 3.4
                   },
                   chassis: {
                       suspension: {
                           front: 'McPherson',
                           rear: 'Chapman',
                       },
                       brakes: :electromagnetic,
                   }
               }, {
                   code: 'M7A',
                   driver: 'Denis Hulme',
                   engine: {
                       power: 333,
                       volume: 5.7
                   },
                   chassis: {
                       suspension: {
                           front: 'multi-link',
                           rear: 'leaf springs',
                       },
                       brakes: :pumping,
                   }
               }],
        colours: [{
                      name: :green,
                      rgb: 0x00FF00,
                  }, {
                      name: :blue,
                      rgb: 0x0000FF,
                  }]
    )

    team.update_attributes(
        name: 'Ferrari',
        year: 1950,
        cars: [{
                   code: '340 F1',
                   driver: 'Ascari',
                   engine: {
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
                   driver: 'Villoresi',
                   engine: {
                       power: 300,
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
                      rgb: 0xFF0000,
                  }, {
                      name: :white,
                      rgb: 0xFFFFFF,
                  }]
    )

    assert_equal('Ferrari', team.name)
    assert_equal(1950,      team.year)

    assert_equal(4, team.cars.size)

    refute(                         team.cars[0].marked_for_destruction?)
    assert_equal('M2B',             team.cars[0].code)
    assert_equal('Bruce McLaren',   team.cars[0].driver)
    assert_equal(363,               team.cars[0].engine.power)
    assert_equal(3.4,               team.cars[0].engine.volume)
    assert_equal('McPherson',       team.cars[0].chassis.suspension.front)
    assert_equal('Chapman',         team.cars[0].chassis.suspension.rear)
    assert_equal(:electromagnetic,  team.cars[0].chassis.brakes)

    refute(                         team.cars[1].marked_for_destruction?)
    assert_equal('M7A',             team.cars[1].code)
    assert_equal('Denis Hulme',     team.cars[1].driver)
    assert_equal(333,               team.cars[1].engine.power)
    assert_equal(5.7,               team.cars[1].engine.volume)
    assert_equal('multi-link',      team.cars[1].chassis.suspension.front)
    assert_equal('leaf springs',    team.cars[1].chassis.suspension.rear)
    assert_equal(:pumping,          team.cars[1].chassis.brakes)

    refute(                         team.cars[2].marked_for_destruction?)
    assert_equal('340 F1',          team.cars[2].code)
    assert_equal('Ascari',          team.cars[2].driver)
    assert_nil(                     team.cars[2].engine.power)              # <- this attribute has nil value because it was not updated and this is new element in the array
    assert_equal(4.1,               team.cars[2].engine.volume)
    assert_equal('independent',     team.cars[2].chassis.suspension.front)
    assert_equal('de Dion',         team.cars[2].chassis.suspension.rear)
    assert_equal(:drum,             team.cars[2].chassis.brakes)

    refute(                         team.cars[3].marked_for_destruction?)
    assert_equal('275 F1',          team.cars[3].code)
    assert_equal('Villoresi',       team.cars[3].driver)
    assert_equal(300,               team.cars[3].engine.power)
    assert_nil(                     team.cars[3].engine.volume)               # <- this attribute has nil value because it was not updated and this is new element in the array
    assert_equal('dependent',       team.cars[3].chassis.suspension.front)
    assert_equal('de Lion',         team.cars[3].chassis.suspension.rear)
    assert_equal(:disc,             team.cars[3].chassis.brakes)

    assert_equal(4, team.colours.size)

    refute(                 team.colours[0].marked_for_destruction?)
    assert_equal(:green,    team.colours[0].name)
    assert_equal(0x00FF00,  team.colours[0].rgb)

    refute(                 team.colours[1].marked_for_destruction?)
    assert_equal(:blue,     team.colours[1].name)
    assert_equal(0x0000FF,  team.colours[1].rgb)

    refute(                 team.colours[2].marked_for_destruction?)
    assert_equal(:red,      team.colours[2].name)
    assert_equal(0xFF0000,  team.colours[2].rgb)

    refute(                 team.colours[3].marked_for_destruction?)
    assert_equal(:white,    team.colours[3].name)
    assert_equal(0xFFFFFF,  team.colours[3].rgb)
  end
end
