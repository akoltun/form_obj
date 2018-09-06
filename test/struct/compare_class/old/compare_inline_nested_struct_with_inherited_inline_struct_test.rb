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




  class InheritedTeam < Team
  end

  def test_class_comparison_with_inherited_class
    assert(Team.eql? InheritedTeam)
    refute(Team.eql? InheritedTeam.new)

    assert(Team === InheritedTeam)
    assert(Team === InheritedTeam.new)

    assert(Team == InheritedTeam)
    refute(Team == InheritedTeam.new)
  end




  class InheritedTeamWithAnotherPrimaryKey < Team
    attribute :car, primary_key: :driver do
      attribute :id
      attribute :driver
      attribute :engine
    end
  end

  def test_class_comparison_with_inherited_class_when_primary_keys_are_different
    refute(Team.eql? InheritedTeamWithAnotherPrimaryKey)
    refute(Team.eql? InheritedTeamWithAnotherPrimaryKey.new)

    refute(Team === InheritedTeamWithAnotherPrimaryKey)
    refute(Team === InheritedTeamWithAnotherPrimaryKey.new)

    refute(Team == InheritedTeamWithAnotherPrimaryKey)
    refute(Team == InheritedTeamWithAnotherPrimaryKey.new)
  end




  class InheritedTeamWithAnotherDefaultValue < Team
    attribute :car do
      attribute :id
      attribute :driver
      attribute :engine, default: 300
    end
  end

  def test_class_comparison_with_inherited_class_when_defaults_are_different
    refute(Team.eql? InheritedTeamWithAnotherDefaultValue)
    refute(Team.eql? InheritedTeamWithAnotherDefaultValue.new)

    refute(Team === InheritedTeamWithAnotherDefaultValue)
    refute(Team === InheritedTeamWithAnotherDefaultValue.new)

    refute(Team == InheritedTeamWithAnotherDefaultValue)
    refute(Team == InheritedTeamWithAnotherDefaultValue.new)
  end




  class InheritedTeamWithArray < Team
    attribute :car, array: true do
      attribute :id
      attribute :driver
      attribute :engine
    end
  end

  def test_class_comparison_with_inherited_class_when_attribute_is_different_because_of_array
    refute(Team.eql? InheritedTeamWithArray)
    refute(Team.eql? InheritedTeamWithArray.new)

    refute(Team === InheritedTeamWithArray)
    refute(Team === InheritedTeamWithArray.new)

    refute(Team == InheritedTeamWithArray)
    refute(Team == InheritedTeamWithArray.new)
  end




  class InheritedTeamWithMoreAttributes < Team
    attribute :car do
      attribute :id
      attribute :driver
      attribute :engine
      attribute :colour
    end
  end

  def test_class_comparison_with_inherited_class_with_more_attributes
    assert(Team.eql? InheritedTeamWithMoreAttributes)
    refute(Team.eql? InheritedTeamWithMoreAttributes.new)

    assert(Team === InheritedTeamWithMoreAttributes)
    assert(Team === InheritedTeamWithMoreAttributes.new)

    assert(Team == InheritedTeamWithMoreAttributes)
    refute(Team == InheritedTeamWithMoreAttributes.new)
  end

  def test_class_comparison_with_inherited_class_with_less_attributes
    refute(InheritedTeamWithMoreAttributes.eql? Team)
    refute(InheritedTeamWithMoreAttributes.eql? Team.new)

    refute(InheritedTeamWithMoreAttributes === Team)
    refute(InheritedTeamWithMoreAttributes === Team.new)

    refute(InheritedTeamWithMoreAttributes == Team)
    refute(InheritedTeamWithMoreAttributes == Team.new)
  end
end
