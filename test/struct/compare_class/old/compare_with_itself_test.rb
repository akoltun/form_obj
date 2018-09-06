require "test_helper"
require "./fill_in_team"

class StructSimpleClassCompareAnotherStructTest < Minitest::Test
  include FillInTeam

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
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
      attribute :chassis, class: 'StructAssignValuesTest::Chassis'
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

    team = fill_in_team(Team.new)

    assert(team.eql? team)
    assert(team === team)
    assert(team == team)
  end
end
