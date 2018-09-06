require "test_helper"

class FormCompareClassWithSimilarStructTest < Minitest::Test
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

  class Suspension1 < FormObj::Struct
    attribute :front
    attribute :rear
  end
  class Chassis1 < FormObj::Struct
    attribute :suspension, class: Suspension1
    attribute :brakes
  end
  class Colour1 < FormObj::Struct
    attribute :name
    attribute :rgb
  end
  class Team1 < FormObj::Struct
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
      attribute :chassis, class: Chassis1
    end
    attribute :colours, class: Colour1, array: true, primary_key: :name
  end

  def test_compare_with_similar_struct
    refute(Team.eql? Team1)
    refute(Team === Team1)
    assert(Team == Team1)

    refute(Team.eql? Team1.new)
    refute(Team === Team1.new)
    refute(Team == Team1.new)
  end
end
