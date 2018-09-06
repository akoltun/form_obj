require "test_helper"

class StructCompareClassWithInheritedWithMoreAndLessAttributesTest < Minitest::Test
  class Car < FormObj::Struct
    attribute :code
    attribute :driver
  end
  class Colour < FormObj::Struct
    attribute :name
    attribute :rgb
  end
  class Team < FormObj::Struct # Default primary key is id
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code, class: Car
    attribute :colour, class: Colour
  end

  class Team1 < Team # Default primary key is id
    attribute :founder
  end

  class Car2 < Car
    attribute :power
  end

  class Team2 < Team # Default primary key is id
    attribute :cars, array: true, primary_key: :code, class: Car2
  end

  class Colour3 < Colour
    attribute :cmyk
  end
  class Team3 < Team # Default primary key is id
    attribute :colour, class: Colour3
  end

  def test_inherited_more_attributes
    assert(Team.eql? Team1)
    assert(Team === Team1)
    assert(Team == Team1)

    refute(Team.eql? Team1.new)
    assert(Team === Team1.new)
    refute(Team == Team1.new)
  end

  def test_inherited_more_array_attributes
    assert(Team.eql? Team2)
    assert(Team === Team2)
    assert(Team == Team2)

    refute(Team.eql? Team2.new)
    assert(Team === Team2.new)
    refute(Team == Team2.new)
  end

  def test_inherited_more_nested_attributes
    assert(Team.eql? Team3)
    assert(Team === Team3)
    assert(Team == Team3)

    refute(Team.eql? Team3.new)
    assert(Team === Team3.new)
    refute(Team == Team3.new)
  end

  def test_ancestor_more_attributes
    refute(Team1.eql? Team)
    refute(Team1 === Team)
    refute(Team1 == Team)

    refute(Team1.eql? Team.new)
    refute(Team1 === Team.new)
    refute(Team1 == Team.new)
  end

  def test_ancestor_more_array_attributes
    refute(Team2.eql? Team)
    refute(Team2 === Team)
    refute(Team2 == Team)

    refute(Team2.eql? Team.new)
    refute(Team2 === Team.new)
    refute(Team2 == Team.new)
  end

  def test_ancestor_more_nested_attributes
    refute(Team3.eql? Team)
    refute(Team3 === Team)
    refute(Team3 == Team)

    refute(Team3.eql? Team.new)
    refute(Team3 === Team.new)
    refute(Team3 == Team.new)
  end
end
