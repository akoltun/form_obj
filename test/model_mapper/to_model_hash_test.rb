require "test_helper"

class ModelMapperToModelHashTest < Minitest::Test
  class DriversChampionship < FormObj::Form
    include FormObj::ModelMapper

    attribute :driver
    attribute :year
  end

  class Sponsor < FormObj::Form
    include FormObj::ModelMapper

    attribute :title
    attribute :money
  end

  class ConstructorsChampionship < FormObj::Form
    include FormObj::ModelMapper

    attribute :year
  end

  class Team < FormObj::Form
    include FormObj::ModelMapper

    attribute :name, model_attribute: :team_name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
    end
    attribute :sponsors, class: Sponsor, array: true, model_attribute: 'finance.:sponsors', primary_key: :title 
    attribute :chassis, array: true, model_hash: true, model: :chassis do
      attribute :id
      attribute :suspension do
        attribute :front
        attribute :rear
      end
      attribute :brakes
    end
    attribute :colours, array: true, model_nesting: false, primary_key: :name do
      attribute :name
      attribute :rgb
    end
    attribute :drivers_championships, array: true, model_attribute: false, class: DriversChampionship, primary_key: :year
    attribute :constructors_championships, array: true, model_attribute: false, class: ConstructorsChampionship, primary_key: :year
  end

  def setup
    @team = Team.new

    @expected_hash = {
        default: {
            team_name: nil,
            year: nil,
            cars: [],
            finance: {
                sponsors: [],
            },
            self: [],
        },
        chassis: {
            chassis: [],
        }
    }
  end

  def fill_in_form
    @expected_hash = {
        default: {
            team_name: 'McLaren',
            year: 1966,
            cars: [{
                       code: '340 F1',
                       driver: 'Bruce McLaren',
                       engine: {
                           power: 300,
                           volume: 3.1,
                       }
                   }, {
                       code: 'M7A',
                       driver: 'Denis Hulme',
                       engine: {
                           power: 415,
                           volume: 4.3
                       }
                   }],
            finance: {
                sponsors: [{
                               title: 'Shell',
                               money: 250
                           }, {
                               title: 'Total',
                               money: 3000,
                           }],
            },
            self: [{
                       name: 'red',
                       rgb: 0xFF0000,
                   }, {
                       name: 'green',
                       rgb: 0x00FF00,
                   }, {
                       name: 'blue',
                       rgb: 0x0000FF,
                   }],
        },
        chassis: {
            chassis: [{
                          id: 1,
                          suspension: {
                              front: 'independent',
                              rear: 'de Dion',
                          },
                          brakes: :drum
                      }, {
                          id: 3,
                          suspension: {
                              front: 'dependent',
                              rear: 'de Lion',
                          },
                          brakes: :disc
                      }],
        }
    }

    @team.name = 'McLaren'
    @team.year = 1966

    car = @team.cars.create
    car.code = '340 F1'
    car.driver = 'Bruce McLaren'
    car.engine.power = 300
    car.engine.volume = 3.1

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
    colour.name = 'red'
    colour.rgb = 0xFF0000

    colour = @team.colours.create
    colour.name = 'green'
    colour.rgb = 0x00FF00

    colour = @team.colours.create
    colour.name = 'blue'
    colour.rgb = 0x0000FF

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

  def test_that_to_model_hash_returns_hash_repsesentation_of_default_model_for_empty_form
    assert_equal(@expected_hash[:default], @team.to_model_hash)
    assert_equal(@expected_hash[:default], @team.to_model_hash(:default))
  end

  def test_that_to_model_hash_returns_hash_repsesentation_of_chassis_model_for_empty_form
    assert_equal(@expected_hash[:chassis], @team.to_model_hash(:chassis))
  end

  def test_that_to_model_hash_returns_hash_repsesentation_of_all_models_for_empty_form
    assert_equal(@expected_hash, @team.to_models_hash)
  end

  def test_that_to_model_hash_returns_hash_repsesentation_of_default_model_for_filled_form
    fill_in_form

    assert_equal(@expected_hash[:default], @team.to_model_hash)
    assert_equal(@expected_hash[:default], @team.to_model_hash(:default))
  end

  def test_that_to_model_hash_returns_hash_repsesentation_of_chassis_model_for_filled_form
    fill_in_form

    assert_equal(@expected_hash[:chassis], @team.to_model_hash(:chassis))
  end

  def test_that_to_model_hash_returns_hash_repsesentation_of_all_models_for_filled_form
    fill_in_form

    assert_equal(@expected_hash, @team.to_models_hash)
  end
end