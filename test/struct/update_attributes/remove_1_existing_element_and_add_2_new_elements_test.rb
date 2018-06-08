require "test_helper"

class StructUpdateAttributesAndRemoveOneExistingElementAndAddTwoNewElementsTest < Minitest::Test
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
      attribute :chassis, class: 'StructUpdateAttributesAndRemoveOneExistingElementAndAddTwoNewElementsTest::Chassis'
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
               }],
        colours: [{
                      name: :green,
                      rgb: 0x00FF00,
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

    assert_equal(2, team.cars.size)

    assert_equal('340 F1',      team.cars[0].code)
    assert_equal('Ascari',      team.cars[0].driver)
    assert_nil(                 team.cars[0].engine.power)              # <- this attribute has nil value because it was not updated and this is new element in the array
    assert_equal(4.1,           team.cars[0].engine.volume)
    assert_equal('independent', team.cars[0].chassis.suspension.front)
    assert_equal('de Dion',     team.cars[0].chassis.suspension.rear)
    assert_equal(:drum,         team.cars[0].chassis.brakes)

    assert_equal('275 F1',    team.cars[1].code)
    assert_equal('Villoresi', team.cars[1].driver)
    assert_equal(300,         team.cars[1].engine.power)
    assert_nil(               team.cars[1].engine.volume)               # <- this attribute has nil value because it was not updated and this is new element in the array
    assert_equal('dependent', team.cars[1].chassis.suspension.front)
    assert_equal('de Lion',   team.cars[1].chassis.suspension.rear)
    assert_equal(:disc,       team.cars[1].chassis.brakes)

    assert_equal(2, team.colours.size)

    assert_equal(:red,      team.colours[0].name)
    assert_equal(0xFF0000,  team.colours[0].rgb)

    assert_equal(:white,    team.colours[1].name)
    assert_equal(0xFFFFFF,  team.colours[1].rgb)
  end
end
