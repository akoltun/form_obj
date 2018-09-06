require "test_helper"

class FormCompareClassWithDifferentPrimaryKeyTest < Minitest::Test
  class Colour < FormObj::Form
    attribute :name
    attribute :rgb
  end
  class Team < FormObj::Form # Default primary key is id
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
    end
    attribute :colours, class: Colour, array: true, primary_key: :name
  end

  class Colour1 < FormObj::Form
    attribute :name
    attribute :rgb
  end
  class Team1 < FormObj::Form
    attribute :name, primary_key: true
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
    end
    attribute :colours, class: Colour1, array: true, primary_key: :name
  end

  class Colour2 < FormObj::Form
    attribute :name
    attribute :rgb
  end
  class Team2 < FormObj::Form
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :driver do
      attribute :code
      attribute :driver
    end
    attribute :colours, class: Colour2, array: true, primary_key: :name
  end

  class Colour3 < FormObj::Form
    attribute :name
    attribute :rgb
  end
  class Team3 < FormObj::Form
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
    end
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
