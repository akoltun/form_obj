require "test_helper"

class DefaultValueTest < Minitest::Test
  class Suspension < FormObj::Struct
    attribute :front
    attribute :rear
  end

  class Chassis < FormObj::Struct
    attribute :suspension, class: Suspension
    attribute :brakes
  end

  class Car < FormObj::Struct
    attribute :code, primary_key: true
    attribute :driver
    attribute :engine, default: ->(struct_class, attribute) { {power: 100, volume: 5.0} } do
      attribute :power
      attribute :volume
    end
    attribute :chassis, class: Chassis
    attribute :colours, array: true, primary_key: :name do
      attribute :name
      attribute :rgb
    end
  end

  class Team < FormObj::Struct
    attribute :name, default: 'Ferrari'
    attribute :year, default: ->(struct_class, attribute) { struct_class.default_year(attribute) }

    attribute :main_car, class: Car, default: {
        code: '340 F1',
        driver: 'Ascari',
        engine: {
            power: 650,
            volume: 3.2
        },
        chassis: {
            suspension: {
                front: 'independent'
            },
        },
        colours: [{name: :red, rgb: 0xFF0000}, {name: :white, rgb: 0xFFFFFF}],
    }
    attribute :second_car, class: Car, default: Car.new(
        code: '340 F1',
        driver: 'Ascari',
        chassis: {
            suspension: {
                front: 'independent'
            },
        },
        colours: [{name: :red, rgb: 0xFF0000}, {name: :white, rgb: 0xFFFFFF}],
        )
    attribute :third_car, class: Car, default: ->(*) {{
        code: '340 F1',
        driver: 'Ascari',
        engine: {
            power: 650,
        },
        chassis: {
            suspension: {
                front: 'independent'
            },
        },
        colours: [{name: :red, rgb: 0xFF0000}, {name: :white, rgb: 0xFFFFFF}],
    }}
    attribute :forth_car, class: Car, default: ->(*) { Car.new(
        code: '340 F1',
        driver: 'Ascari',
        engine: {
            volume: 3.2
        },
        chassis: {
            suspension: {
                front: 'independent'
            },
        },
        colours: [{name: :red, rgb: 0xFF0000}, {name: :white, rgb: 0xFFFFFF}],
        ) }
    attribute :wrong_car, class: Car, default: ->(*) { 'wrong default value' }

    attribute :main_cars, array: true, primary_key: :code, class: Car, default: [
        {
            code: '340 F1',
            driver: 'Ascari',
            engine: {
                power: 650,
                volume: 3.2
            },
            chassis: {
                suspension: {
                    front: 'independent'
                },
            },
            colours: [{name: :red, rgb: 0xFF0000}, {name: :white, rgb: 0xFFFFFF}],
        },
        Car.new(
            code: '275 F1',
            driver: 'Villoresi',
            chassis: {
                suspension: {
                    front: 'dependent'
                },
            },
            colours: [{name: :blue, rgb: 0x0000FF}, {name: :green, rgb: 0x00FF00}],
            )
    ]

    attribute :additional_cars, array: true, primary_key: :code, class: Car, default: ->(*) {
      [
          {
              code: '340 F1',
              driver: 'Ascari',
              engine: {
                  power: 650,
                  volume: 3.2
              },
              chassis: {
                  suspension: {
                      front: 'independent'
                  },
              },
              colours: [{name: :red, rgb: 0xFF0000}, {name: :white, rgb: 0xFFFFFF}],
          },
          Car.new(
              code: '275 F1',
              driver: 'Villoresi',
              chassis: {
                  suspension: {
                      front: 'dependent'
                  },
              },
              colours: [{name: :blue, rgb: 0x0000FF}, {name: :green, rgb: 0x00FF00}],
              ),
      ]
    }

    attribute :wrong_cars1, array: true, class: Car, default: ->(*) { 'wrong default value' }
    attribute :wrong_cars2, array: true, class: Car, default: ->(*) { ['wrong default value'] }

    def self.default_year(attribute)
      "#{attribute.name} = 1950"
    end
  end

  def test_that_all_attributes_got_correct_default_values
    team = Team.new

    assert_equal('Ferrari', team.name)
    assert_equal('year = 1950', team.year)

    assert_equal('340 F1',      team.main_car.code)
    assert_equal('Ascari',      team.main_car.driver)
    assert_equal(650,           team.main_car.engine.power)                 # <- Default value defined in outer class overlaps default value defined in nested class
    assert_equal(3.2,           team.main_car.engine.volume)                # <- Default value defined in outer class overlaps default value defined in nested class
    assert_equal('independent', team.main_car.chassis.suspension.front)
    assert_nil(                 team.main_car.chassis.suspension.rear)
    assert_nil(                 team.main_car.chassis.brakes)
    assert_equal(2,             team.main_car.colours.size)
    assert_equal(:red,          team.main_car.colours[0].name)
    assert_equal(0xFF0000,      team.main_car.colours[0].rgb)
    assert_equal(:white,        team.main_car.colours[1].name)
    assert_equal(0xFFFFFF,      team.main_car.colours[1].rgb)

    assert_equal('340 F1',      team.second_car.code)
    assert_equal('Ascari',      team.second_car.driver)
    assert_equal(100,           team.second_car.engine.power)               # <- Default value defined in nested class
    assert_equal(5.0,           team.second_car.engine.volume)              # <- Default value defined in nested class
    assert_equal('independent', team.second_car.chassis.suspension.front)
    assert_nil(                 team.second_car.chassis.suspension.rear)
    assert_nil(                 team.second_car.chassis.brakes)
    assert_equal(2,             team.second_car.colours.size)
    assert_equal(:red,          team.second_car.colours[0].name)
    assert_equal(0xFF0000,      team.second_car.colours[0].rgb)
    assert_equal(:white,        team.second_car.colours[1].name)
    assert_equal(0xFFFFFF,      team.second_car.colours[1].rgb)

    assert_equal('340 F1',      team.third_car.code)
    assert_equal('Ascari',      team.third_car.driver)
    assert_equal(650,           team.third_car.engine.power)                # <- Default value defined in outer class overlaps default value defined in nested class
    assert_equal(5.0,           team.third_car.engine.volume)               # <- Default value defined in nested class
    assert_equal('independent', team.third_car.chassis.suspension.front)
    assert_nil(                 team.third_car.chassis.suspension.rear)
    assert_nil(                 team.third_car.chassis.brakes)
    assert_equal(2,             team.third_car.colours.size)
    assert_equal(:red,          team.third_car.colours[0].name)
    assert_equal(0xFF0000,      team.third_car.colours[0].rgb)
    assert_equal(:white,        team.third_car.colours[1].name)
    assert_equal(0xFFFFFF,      team.third_car.colours[1].rgb)

    assert_equal('340 F1',      team.forth_car.code)
    assert_equal('Ascari',      team.forth_car.driver)
    assert_equal(100,           team.forth_car.engine.power)                # <- Default value defined in nested class
    assert_equal(3.2,           team.forth_car.engine.volume)               # <- Default value defined in outer class overlaps default value defined in nested class
    assert_equal('independent', team.forth_car.chassis.suspension.front)
    assert_nil(                 team.forth_car.chassis.suspension.rear)
    assert_nil(                 team.forth_car.chassis.brakes)
    assert_equal(2,             team.forth_car.colours.size)
    assert_equal(:red,          team.forth_car.colours[0].name)
    assert_equal(0xFF0000,      team.forth_car.colours[0].rgb)
    assert_equal(:white,        team.forth_car.colours[1].name)
    assert_equal(0xFFFFFF,      team.forth_car.colours[1].rgb)

    assert_raises(FormObj::WrongDefaultValueClass) { team.wrong_car }

    assert_equal(2, team.main_cars.size)

    assert_equal('340 F1',      team.main_cars[0].code)
    assert_equal('Ascari',      team.main_cars[0].driver)
    assert_equal(650,           team.main_cars[0].engine.power)                 # <- Default value defined in outer class overlaps default value defined in nested class
    assert_equal(3.2,           team.main_cars[0].engine.volume)                # <- Default value defined in outer class overlaps default value defined in nested class
    assert_equal('independent', team.main_cars[0].chassis.suspension.front)
    assert_nil(                 team.main_cars[0].chassis.suspension.rear)
    assert_nil(                 team.main_cars[0].chassis.brakes)
    assert_equal(2,             team.main_cars[0].colours.size)
    assert_equal(:red,          team.main_cars[0].colours[0].name)
    assert_equal(0xFF0000,      team.main_cars[0].colours[0].rgb)
    assert_equal(:white,        team.main_cars[0].colours[1].name)
    assert_equal(0xFFFFFF,      team.main_cars[0].colours[1].rgb)

    assert_equal('275 F1',      team.main_cars[1].code)
    assert_equal('Villoresi',   team.main_cars[1].driver)
    assert_equal(100,           team.main_cars[1].engine.power)                 # <- Default value defined in nested class
    assert_equal(5.0,           team.main_cars[1].engine.volume)                # <- Default value defined in nested class
    assert_equal('dependent',   team.main_cars[1].chassis.suspension.front)
    assert_nil(                 team.main_cars[1].chassis.suspension.rear)
    assert_nil(                 team.main_cars[1].chassis.brakes)
    assert_equal(2,             team.main_cars[1].colours.size)
    assert_equal(:blue,         team.main_cars[1].colours[0].name)
    assert_equal(0x0000FF,      team.main_cars[1].colours[0].rgb)
    assert_equal(:green,        team.main_cars[1].colours[1].name)
    assert_equal(0x00FF00,      team.main_cars[1].colours[1].rgb)

    assert_equal(2, team.additional_cars.size)

    assert_equal('340 F1',      team.additional_cars[0].code)
    assert_equal('Ascari',      team.additional_cars[0].driver)
    assert_equal(650,           team.additional_cars[0].engine.power)                 # <- Default value defined in outer class overlaps default value defined in nested class
    assert_equal(3.2,           team.additional_cars[0].engine.volume)                # <- Default value defined in outer class overlaps default value defined in nested class
    assert_equal('independent', team.additional_cars[0].chassis.suspension.front)
    assert_nil(                 team.additional_cars[0].chassis.suspension.rear)
    assert_nil(                 team.additional_cars[0].chassis.brakes)
    assert_equal(2,             team.additional_cars[0].colours.size)
    assert_equal(:red,          team.additional_cars[0].colours[0].name)
    assert_equal(0xFF0000,      team.additional_cars[0].colours[0].rgb)
    assert_equal(:white,        team.additional_cars[0].colours[1].name)
    assert_equal(0xFFFFFF,      team.additional_cars[0].colours[1].rgb)

    assert_equal('275 F1',      team.additional_cars[1].code)
    assert_equal('Villoresi',   team.additional_cars[1].driver)
    assert_equal(100,           team.additional_cars[1].engine.power)                 # <- Default value defined in nested class
    assert_equal(5.0,           team.additional_cars[1].engine.volume)                # <- Default value defined in nested class
    assert_equal('dependent',   team.additional_cars[1].chassis.suspension.front)
    assert_nil(                 team.additional_cars[1].chassis.suspension.rear)
    assert_nil(                 team.additional_cars[1].chassis.brakes)
    assert_equal(2,             team.additional_cars[1].colours.size)
    assert_equal(:blue,         team.additional_cars[1].colours[0].name)
    assert_equal(0x0000FF,      team.additional_cars[1].colours[0].rgb)
    assert_equal(:green,        team.additional_cars[1].colours[1].name)
    assert_equal(0x00FF00,      team.additional_cars[1].colours[1].rgb)

    assert_raises(FormObj::WrongDefaultValueClass) { team.wrong_cars1 }
    assert_raises(FormObj::WrongDefaultValueClass) { team.wrong_cars2 }
  end
end
