require "test_helper"

class StructSimpleClassCompareWithNonFormObjStructTest < Minitest::Test
  class Team < FormObj::Struct
    attribute :id # primary key by default
    attribute :name
    attribute :year
  end

  AnotherTeam = Struct.new(:id, :name, :year)

  def test_compare_with_non_form_obj_struct
    refute(Team.eql? AnotherTeam)
    refute(Team.eql? AnotherTeam.new)

    refute(Team === AnotherTeam)
    refute(Team === AnotherTeam.new)

    refute(Team == AnotherTeam)
    refute(Team == AnotherTeam.new)
  end
end
