require "test_helper"

class ModelMapperToHashTest < Minitest::Test
  class Suspension < FormObj::Form
    include FormObj::ModelMapper

    attribute :front
    attribute :rear
  end
  class Chassis < FormObj::Form
    include FormObj::ModelMapper

    attribute :suspension, class: Suspension
    attribute :brakes
  end
  class Colour < FormObj::Form
    include FormObj::ModelMapper

    attribute :name
    attribute :rgb
  end
  class Team < FormObj::Form
    include FormObj::ModelMapper

    attribute :name
    attribute :year
    attribute :cars, array: true do
      attribute :code, primary_key: true
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
      attribute :chassis, class: 'ModelMapperToHashTest::Chassis'
    end
    attribute :colours, class: Colour, array: true, primary_key: :name
  end

  def test_that_to_hash_returns_correct_hash_representation
    hash = {
        name: 'Ferrari',
        year: 1950,
        cars: [{
                   code: '340 F1',
                   driver: 'Ascari',
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
                      rgb: 0xFF0000,
                  }, {
                      name: :white,
                      rgb: 0xFFFFFF,
                  }]
    }

    assert_equal(hash, Team.new(hash).to_hash)
  end
end
