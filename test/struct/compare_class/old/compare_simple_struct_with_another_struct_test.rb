require "test_helper"

class StructSimpleClassCompareAnotherStructTest < Minitest::Test
  class Team < FormObj::Struct
    attribute :id # primary key by default
    attribute :name
    attribute :year
  end

  def test_compare_with_itself
    assert(Team.eql? Team)
    refute(Team.eql? Team.new)

    assert(Team === Team)
    assert(Team === Team.new)

    assert(Team == Team)
    refute(Team == Team.new)
  end




  class AnotherTeam < FormObj::Struct
    attribute :id # primary key by default
    attribute :name
    attribute :year
  end

  def test_compare_with_another
    refute(Team.eql? AnotherTeam)
    refute(Team.eql? AnotherTeam.new)

    refute(Team === AnotherTeam)
    refute(Team === AnotherTeam.new)

    assert(Team == AnotherTeam)
    refute(Team == AnotherTeam.new)
  end




  class TeamWithAnotherPrimaryKey < FormObj::Struct
    attribute :id
    attribute :name, primary_key: true
    attribute :year
  end

  def test_primary_key_differs
    refute(Team.eql? TeamWithAnotherPrimaryKey)
    refute(Team.eql? TeamWithAnotherPrimaryKey.new)

    refute(Team === TeamWithAnotherPrimaryKey)
    refute(Team === TeamWithAnotherPrimaryKey.new)

    refute(Team == TeamWithAnotherPrimaryKey)
    refute(Team == TeamWithAnotherPrimaryKey.new)
  end



  class TeamWithAnotherDefaultValue < FormObj::Struct
    attribute :id # primary key by default
    attribute :name
    attribute :year, default: 1950
  end

  def test_default_value_differs
    refute(Team.eql? TeamWithAnotherDefaultValue)
    refute(Team.eql? TeamWithAnotherDefaultValue.new)

    refute(Team === TeamWithAnotherDefaultValue)
    refute(Team === TeamWithAnotherDefaultValue.new)

    refute(Team == TeamWithAnotherDefaultValue)
    refute(Team == TeamWithAnotherDefaultValue.new)
  end



  class TeamWithNestedForm < FormObj::Struct
    attribute :id # primary key by default
    attribute :name
    attribute :year do
      attribute :as_number
      attribute :as_text
    end
  end

  def test_compare_simple_attribute_with_nested
    refute(Team.eql? TeamWithNestedForm)
    refute(Team.eql? TeamWithNestedForm.new)

    refute(Team === TeamWithNestedForm)
    refute(Team === TeamWithNestedForm.new)

    refute(Team == TeamWithNestedForm)
    refute(Team == TeamWithNestedForm.new)
  end



  class TeamWithArray < FormObj::Struct
    attribute :id # primary key by default
    attribute :name
    attribute :year, array: true do
      attribute :as_number
      attribute :as_text
    end
  end

  def test_compare_simple_attribute_with_array
    refute(Team.eql? TeamWithArray)
    refute(Team.eql? TeamWithArray.new)

    refute(Team === TeamWithArray)
    refute(Team === TeamWithArray.new)

    refute(Team == TeamWithArray)
    refute(Team == TeamWithArray.new)
  end



  class TeamWithMoreAttributes < FormObj::Struct
    attribute :id # primary key by default
    attribute :name
    attribute :year
    attribute :founder
  end

  def test_compare_with_more_attributes
    refute(Team.eql? TeamWithMoreAttributes)
    refute(Team.eql? TeamWithMoreAttributes.new)

    refute(Team === TeamWithMoreAttributes)
    refute(Team === TeamWithMoreAttributes.new)

    assert(Team == TeamWithMoreAttributes)
    refute(Team == TeamWithMoreAttributes.new)
  end

  def test_compare_with_less_attributes
    refute(TeamWithMoreAttributes.eql? Team)
    refute(TeamWithMoreAttributes.eql? Team.new)

    refute(TeamWithMoreAttributes === Team)
    refute(TeamWithMoreAttributes === Team.new)

    refute(TeamWithMoreAttributes == Team)
    refute(TeamWithMoreAttributes == Team.new)
  end
end
