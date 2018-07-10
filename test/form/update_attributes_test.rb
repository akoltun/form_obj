require "test_helper"

class FormUpdateAttributesTest < Minitest::Test
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
      attribute :chassis, class: 'FormUpdateAttributesTest::Chassis'
    end
    attribute :colours, class: Colour, array: true, primary_key: :name
  end

  def test_that_all_attributes_are_correctly_updated
    team = Team.new(
        name: 'McLaren',
        year: 1966,
        cars: [{
                   code: '340 F1',
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
                       brakes: :fantasctic,
                   }
               }, {
                   code: '275 F1',
                   driver: 'Villoresi',
                   engine: {
                       power: 333,
                       volume: 5.7
                   },
                   chassis: {
                       suspension: {
                           front: 'multi-link',
                           rear: 'leaf springs',
                       },
                       brakes: :electromagnetic,
                   }
               }, {
                   code: '350 F1',
                   driver: 'James Hunt',
                   engine: {
                       power: 408,
                       volume: 3.0
                   },
                   chassis: {
                       suspension: {
                           front: 'semi trailing arm',
                           rear: 'swing axle',
                       },
                       brakes: :frictional,
                   }
               }, {
                   code: '360 F1',
                   driver: 'Jim Clark',
                   engine: {
                       power: 415,
                       volume: 3.2
                   },
                   chassis: {
                       suspension: {
                           front: 'fantastic',
                           rear: 'strange',
                       },
                       brakes: :legs,
                   }
               }],
        colours: [{
                      name: :red,
                      rgb: 0x00FF00,
                  }, {
                      name: :green,
                      rgb: 0x00FF00,
                  }, {
                      name: :blue,
                      rgb: 0x0000FF,
                  }, {
                      name: :white,
                      rgb: 0xFFFFFF,
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
                   code: '350 F1',
                   driver: 'Denis Hulme',
                   engine: {
                       power: 300,
                   },
                   chassis: {
                       suspension: {
                           front: 'dependent',
                           rear: 'de Lion',
                       },
                       brakes: :disc,
                   },
                   _destroy: false,
               }, {
                   code: '360 F1',
                   _destroy: true,
                   chassis: {
                       brakes: :hands,
                   }
               }, {
                   code: 'Tipo 625',
                   driver: 'Gonzalez',
                   engine: {
                       volume: 2.5,
                       power: 220,
                   },
                   chassis: {
                       suspension: {
                           front: 'abcd',
                           rear: 'efgh',
                       },
                       brakes: :shoes,
                   },
                   _destroy: true,
               }],
        colours: [{
                      name: :red,
                      rgb: 0xFE0000,
                  }, {
                      name: :blue,
                      rgb: 0x0000FE,
                      _destroy: false
                  }, {
                      name: :white,
                      _destroy: true,
                  }]
    )

    assert_equal('Ferrari', team.name)
    assert_equal(1950,      team.year)

    assert_equal(4, team.cars.size)
    assert_equal(['275 F1', '340 F1', '350 F1', '360 F1'], team.cars.map(&:code).sort)

    car = team.cars.find { |car| car.code == '275 F1' }
    refute(                           car.marked_for_destruction?)
    assert_equal('Villoresi',         car.driver)
    assert_equal(333,                 car.engine.power)
    assert_equal(5.7,                 car.engine.volume)
    assert_equal('multi-link',        car.chassis.suspension.front)
    assert_equal('leaf springs',      car.chassis.suspension.rear)
    assert_equal(:electromagnetic,    car.chassis.brakes)

    car = team.cars.find { |car| car.code == '340 F1' }
    refute(                           car.marked_for_destruction?)
    assert_equal('Ascari',            car.driver)
    assert_equal(363,                 car.engine.power)                # <- this attribute keeps value because it was not updated and this is old element in the array
    assert_equal(4.1,                 car.engine.volume)
    assert_equal('independent',       car.chassis.suspension.front)
    assert_equal('de Dion',           car.chassis.suspension.rear)
    assert_equal(:drum,               car.chassis.brakes)

    car = team.cars.find { |car| car.code == '350 F1' }
    refute(                           car.marked_for_destruction?)
    assert_equal('Denis Hulme',       car.driver)
    assert_equal(300,                 car.engine.power)
    assert_equal(3.0,                 car.engine.volume)               # <- this attribute keeps value because it was not updated and this is old element in the array
    assert_equal('dependent',         car.chassis.suspension.front)
    assert_equal('de Lion',           car.chassis.suspension.rear)
    assert_equal(:disc,               car.chassis.brakes)

    car = team.cars.find { |car| car.code == '360 F1' }
    assert(                           car.marked_for_destruction?)
    assert_equal('Jim Clark',         car.driver)
    assert_equal(415,                 car.engine.power)
    assert_equal(3.2,                 car.engine.volume)               # <- this attribute keeps value because it was not updated and this is old element in the array
    assert_equal('fantastic',         car.chassis.suspension.front)
    assert_equal('strange',           car.chassis.suspension.rear)
    assert_equal(:legs,               car.chassis.brakes)

    assert_equal(4, team.colours.size)
    assert_equal(%i{blue green red white}, team.colours.map(&:name).sort)

    colour = team.colours.find { |colour| colour.name == :green }
    refute(                 colour.marked_for_destruction?)
    assert_equal(0x00FF00,  colour.rgb)

    colour = team.colours.find { |colour| colour.name == :red }
    refute(                 colour.marked_for_destruction?)
    assert_equal(0xFE0000,  colour.rgb)

    colour = team.colours.find { |colour| colour.name == :blue }
    refute(                 colour.marked_for_destruction?)
    assert_equal(0x0000FE,  colour.rgb)

    colour = team.colours.find { |colour| colour.name == :white }
    assert(                 colour.marked_for_destruction?)
    assert_equal(0xFFFFFF,  colour.rgb)
  end
end
