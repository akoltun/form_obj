require "test_helper"

class StructCompareClassWithInheritedWithDifferentPrimaryKeyTest < Minitest::Test
  class Colour < FormObj::Struct
    attribute :name
    attribute :rgb
  end
  class Team < FormObj::Struct # Default primary key is id
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
    end
    attribute :colours, class: Colour, array: true, primary_key: :name
  end

  class Team1 < Team
    attribute :name, primary_key: true
  end

  class Team2 < Team
    attribute :cars, array: true, primary_key: :driver do
      attribute :code
      attribute :driver
    end
  end

  class Colour3 < Colour
  end
  class Team3 < Team
    attribute :colours, class: Colour3, array: true, primary_key: :rgb
  end

  def test_different_primary_key
    refute(Team.eql? Team1)
    refute(Team === Team1)
    refute(Team == Team1)

    refute(Team.eql? Team1.new)
    refute(Team === Team1.new)
    refute(Team == Team1.new)
  end

  def test_different_nested_primary_key_inline_definition
    refute(Team.eql? Team2)
    refute(Team === Team2)
    refute(Team == Team2)

    refute(Team.eql? Team2.new)
    refute(Team === Team2.new)
    refute(Team == Team2.new)
  end

  def test_different_nested_primary_key_external_class_definition
    refute(Team.eql? Team3)
    refute(Team === Team3)
    refute(Team == Team3)

    refute(Team.eql? Team3.new)
    refute(Team === Team3.new)
    refute(Team == Team3.new)
  end
end
