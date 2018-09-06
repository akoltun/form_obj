require "test_helper"

class StructNestedClassComparisonTest < Minitest::Test
  class Team < FormObj::Struct
    attribute :name
    attribute :car do
      attribute :id # primary key by default
      attribute :driver
      attribute :engine
    end
  end

  def test_class_comparison_with_itself
    assert(Team.eql? Team)
    refute(Team.eql? Team.new)

    assert(Team === Team)
    assert(Team === Team.new)

    assert(Team == Team)
    refute(Team == Team.new)
  end




  class AnotherTeam < FormObj::Struct
    attribute :name
    attribute :car do
      attribute :id # primary key by default
      attribute :driver
      attribute :engine
    end
  end

  def test_class_comparison_with_similar_class
    refute(Team.eql? AnotherTeam)
    refute(Team.eql? AnotherTeam.new)

    refute(Team === AnotherTeam)
    refute(Team === AnotherTeam.new)

    assert(Team == AnotherTeam)
    refute(Team == AnotherTeam.new)
  end




  class TeamWithAnotherPrimaryKey < FormObj::Struct
    attribute :name
    attribute :car, primary_key: :driver do
      attribute :id
      attribute :driver
      attribute :engine
    end
  end

  def test_class_comparison_with_another_class_when_primary_keys_are_different
    refute(Team.eql? TeamWithAnotherPrimaryKey)
    refute(Team.eql? TeamWithAnotherPrimaryKey.new)

    refute(Team === TeamWithAnotherPrimaryKey)
    refute(Team === TeamWithAnotherPrimaryKey.new)

    refute(Team == TeamWithAnotherPrimaryKey)
    refute(Team == TeamWithAnotherPrimaryKey.new)
  end




  class TeamWithAnotherDefaultValue < FormObj::Struct
    attribute :name
    attribute :car do
      attribute :id # primary key by default
      attribute :driver
      attribute :engine, default: 'I2'
    end
  end

  def test_class_comparison_with_another_class_when_defaults_are_different
    refute(Team.eql? TeamWithAnotherDefaultValue)
    refute(Team.eql? TeamWithAnotherDefaultValue.new)

    refute(Team === TeamWithAnotherDefaultValue)
    refute(Team === TeamWithAnotherDefaultValue.new)

    refute(Team == TeamWithAnotherDefaultValue)
    refute(Team == TeamWithAnotherDefaultValue.new)
  end




  class TeamWithArray < FormObj::Struct
    attribute :name
    attribute :car, array: true do
      attribute :id # primary key by default
      attribute :driver
      attribute :engine
    end
  end

  def test_class_comparison_with_another_class_when_attribute_is_different_because_of_array
    refute(Team.eql? TeamWithArray)
    refute(Team.eql? TeamWithArray.new)

    refute(Team === TeamWithArray)
    refute(Team === TeamWithArray.new)

    refute(Team == TeamWithArray)
    refute(Team == TeamWithArray.new)
  end




  class TeamWithMoreAttributes < FormObj::Struct
    attribute :name
    attribute :car do
      attribute :id # primary key by default
      attribute :driver
      attribute :engine
      attribute :colour
    end
  end

  def test_class_comparison_with_another_class_with_more_attributes
    refute(Team.eql? TeamWithMoreAttributes)
    refute(Team.eql? TeamWithMoreAttributes.new)

    refute(Team === TeamWithMoreAttributes)
    refute(Team === TeamWithMoreAttributes.new)

    assert(Team == TeamWithMoreAttributes)
    refute(Team == TeamWithMoreAttributes.new)
  end

  def test_class_comparison_with_another_class_with_less_attributes
    refute(TeamWithMoreAttributes.eql? Team)
    refute(TeamWithMoreAttributes.eql? Team.new)

    refute(TeamWithMoreAttributes === Team)
    refute(TeamWithMoreAttributes === Team.new)

    refute(TeamWithMoreAttributes == Team)
    refute(TeamWithMoreAttributes == Team.new)
  end
end
