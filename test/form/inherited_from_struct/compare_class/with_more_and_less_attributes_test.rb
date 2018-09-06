require "test_helper"

class FormCompareClassWithMoreAndLessAttributesTest < Minitest::Test
  class Team < FormObj::Form # Default primary key is id
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
    end
    attribute :colour do
      attribute :name
      attribute :rgb
    end
  end

  class Team1 < FormObj::Form # Default primary key is id
    attribute :name
    attribute :year
    attribute :founder
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
    end
    attribute :colour do
      attribute :name
      attribute :rgb
    end
  end

  class Team2 < FormObj::Form # Default primary key is id
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
      attribute :power
    end
    attribute :colour do
      attribute :name
      attribute :rgb
    end
  end

  class Team3 < FormObj::Form # Default primary key is id
    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
    end
    attribute :colour do
      attribute :name
      attribute :rgb
      attribute :cmyk
    end
  end

  def test_more_attributes
    refute(Team.eql? Team1)
    refute(Team === Team1)
    assert(Team == Team1)

    refute(Team.eql? Team1.new)
    refute(Team === Team1.new)
    refute(Team == Team1.new)
  end

  def test_more_attributes_in_array
    refute(Team.eql? Team2)
    refute(Team === Team2)
    assert(Team == Team2)

    refute(Team.eql? Team2.new)
    refute(Team === Team2.new)
    refute(Team == Team2.new)
  end

  def test_more_nested_attributes
    refute(Team.eql? Team3)
    refute(Team === Team3)
    assert(Team == Team3)

    refute(Team.eql? Team3.new)
    refute(Team === Team3.new)
    refute(Team == Team3.new)
  end

  def test_less_attributes
    refute(Team1.eql? Team)
    refute(Team1 === Team)
    refute(Team1 == Team)

    refute(Team1.eql? Team.new)
    refute(Team1 === Team.new)
    refute(Team1 == Team.new)
  end

  def test_less_attributes_in_array
    refute(Team2.eql? Team)
    refute(Team2 === Team)
    refute(Team2 == Team)

    refute(Team2.eql? Team.new)
    refute(Team2 === Team.new)
    refute(Team2 == Team.new)
  end

  def test_less_nested_attributes
    refute(Team3.eql? Team)
    refute(Team3 === Team)
    refute(Team3 == Team)

    refute(Team3.eql? Team.new)
    refute(Team3 === Team.new)
    refute(Team3 == Team.new)
  end
end
