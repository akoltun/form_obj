require "test_helper"

class FormCompareClassWithItselfTest < Minitest::Test
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
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
      attribute :chassis, class: Chassis
    end
    attribute :colours, class: Colour, array: true, primary_key: :name
  end

  def test_compare_with_itself
    assert(Team.eql? Team)
    assert(Team === Team)
    assert(Team == Team)

    refute(Team.eql? Team.new)
    assert(Team === Team.new)
    refute(Team == Team.new)
  end
end
