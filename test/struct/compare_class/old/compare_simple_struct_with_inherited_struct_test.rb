require "test_helper"

class StructSimpleClassCompareWithInheritedStructTest < Minitest::Test
  class Team < FormObj::Struct
    attribute :id # primary key by default
    attribute :name
    attribute :year
  end

  class InheritedTeam < Team
  end

  def test_compare_with_inherited_class
    assert(Team.eql? InheritedTeam)
    refute(Team.eql? InheritedTeam.new)

    assert(Team === InheritedTeam)
    assert(Team === InheritedTeam.new)

    assert(Team == InheritedTeam)
    refute(Team == InheritedTeam.new)
  end



  class InheritedTeamWithAnotherPrimaryKey < Team
    attribute :name, primary_key: true
  end

  def test_primary_keys_differs
    refute(Team.eql? InheritedTeamWithAnotherPrimaryKey)
    refute(Team.eql? InheritedTeamWithAnotherPrimaryKey.new)

    refute(Team === InheritedTeamWithAnotherPrimaryKey)
    refute(Team === InheritedTeamWithAnotherPrimaryKey.new)

    refute(Team == InheritedTeamWithAnotherPrimaryKey)
    refute(Team == InheritedTeamWithAnotherPrimaryKey.new)
  end



  class InheritedTeamWithAnotherDefaultValue < Team
    attribute :year, default: 1950
  end

  def test_default_value_differs
    refute(Team.eql? InheritedTeamWithAnotherDefaultValue)
    refute(Team.eql? InheritedTeamWithAnotherDefaultValue.new)

    refute(Team === InheritedTeamWithAnotherDefaultValue)
    refute(Team === InheritedTeamWithAnotherDefaultValue.new)

    refute(Team == InheritedTeamWithAnotherDefaultValue)
    refute(Team == InheritedTeamWithAnotherDefaultValue.new)
  end



  class InheritedTeamWithNestedForm < Team
    attribute :year do
      attribute :as_number
      attribute :as_text
    end
  end

  def test_compare_simple_attribute_with_nested
    refute(Team.eql? InheritedTeamWithNestedForm)
    refute(Team.eql? InheritedTeamWithNestedForm.new)

    refute(Team === InheritedTeamWithNestedForm)
    refute(Team === InheritedTeamWithNestedForm.new)

    refute(Team == InheritedTeamWithNestedForm)
    refute(Team == InheritedTeamWithNestedForm.new)
  end



  class InheritedTeamWithArray < Team
    attribute :year, array: true do
      attribute :as_number
      attribute :as_text
    end
  end

  def test_compare_simple_attribute_with_array
    refute(Team.eql? InheritedTeamWithArray)
    refute(Team.eql? InheritedTeamWithArray.new)

    refute(Team === InheritedTeamWithArray)
    refute(Team === InheritedTeamWithArray.new)

    refute(Team == InheritedTeamWithArray)
    refute(Team == InheritedTeamWithArray.new)
  end



  class InheritedTeamWithMoreAttributes < Team
    attribute :founder
  end

  def test_compare_with_more_attributes
    assert(Team.eql? InheritedTeamWithMoreAttributes)
    refute(Team.eql? InheritedTeamWithMoreAttributes.new)

    assert(Team === InheritedTeamWithMoreAttributes)
    assert(Team === InheritedTeamWithMoreAttributes.new)

    assert(Team == InheritedTeamWithMoreAttributes)
    refute(Team == InheritedTeamWithMoreAttributes.new)
  end

  def test_compare_with_less_attributes
    refute(InheritedTeamWithMoreAttributes.eql? Team)
    refute(InheritedTeamWithMoreAttributes.eql? Team.new)

    refute(InheritedTeamWithMoreAttributes === Team)
    refute(InheritedTeamWithMoreAttributes === Team.new)

    refute(InheritedTeamWithMoreAttributes == Team)
    refute(InheritedTeamWithMoreAttributes == Team.new)
  end
end
