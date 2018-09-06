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




  class Car < FormObj::Struct
    attribute :id # primary key by default
    attribute :driver
    attribute :engine
  end
  
  class TeamWithExternalCarClass < FormObj::Struct
    attribute :name
    attribute :car, class: Car
  end

  def test_class_comparison_with_another_class_with_external_car_class
    refute(Team.eql? TeamWithExternalCarClass)
    refute(Team.eql? TeamWithExternalCarClass.new)

    refute(Team === TeamWithExternalCarClass)
    refute(Team === TeamWithExternalCarClass.new)

    assert(Team == TeamWithExternalCarClass)
    refute(Team == TeamWithExternalCarClass.new)
  end



  class CarWithAnotherPrimaryKey < FormObj::Struct
    attribute :id
    attribute :driver, primary_key: true
    attribute :engine
  end

  class TeamWithExternalCarClassWithAnotherPrimaryKey < FormObj::Struct
    attribute :name
    attribute :car, class: CarWithAnotherPrimaryKey
  end

  def test_class_comparison_with_another_class_with_external_car_class_when_primary_keys_are_different
    refute(Team.eql? TeamWithExternalCarClassWithAnotherPrimaryKey)
    refute(Team.eql? TeamWithExternalCarClassWithAnotherPrimaryKey.new)

    refute(Team === TeamWithExternalCarClassWithAnotherPrimaryKey)
    refute(Team === TeamWithExternalCarClassWithAnotherPrimaryKey.new)

    refute(Team == TeamWithExternalCarClassWithAnotherPrimaryKey)
    refute(Team == TeamWithExternalCarClassWithAnotherPrimaryKey.new)
  end




  class CarWithAnotherDefaultValue < FormObj::Struct
    attribute :id # primary key by default
    attribute :driver
    attribute :engine, default: 'I2'
  end
  
  class TeamWithExternalCarClassWithAnotherDefaultValue < FormObj::Struct
    attribute :name
    attribute :car, class: CarWithAnotherDefaultValue
  end

  def test_class_comparison_with_another_class_with_external_car_class_when_default_values_are_different
    refute(Team.eql? TeamWithExternalCarClassWithAnotherDefaultValue)
    refute(Team.eql? TeamWithExternalCarClassWithAnotherDefaultValue.new)

    refute(Team === TeamWithExternalCarClassWithAnotherDefaultValue)
    refute(Team === TeamWithExternalCarClassWithAnotherDefaultValue.new)

    refute(Team == TeamWithExternalCarClassWithAnotherDefaultValue)
    refute(Team == TeamWithExternalCarClassWithAnotherDefaultValue.new)
  end




  class TeamWithExternalCarClassWithArray < FormObj::Struct
    attribute :name
    attribute :car, array: true, class: Car
  end

  def test_class_comparison_with_another_class_with_external_car_class_when_attribute_is_different_because_of_array
    refute(Team.eql? TeamWithExternalCarClassWithArray)
    refute(Team.eql? TeamWithExternalCarClassWithArray.new)

    refute(Team === TeamWithExternalCarClassWithArray)
    refute(Team === TeamWithExternalCarClassWithArray.new)

    refute(Team == TeamWithExternalCarClassWithArray)
    refute(Team == TeamWithExternalCarClassWithArray.new)
  end




  class CarWithMoreAttributes < FormObj::Struct
    attribute :id # primary key by default
    attribute :driver
    attribute :engine
    attribute :colour
  end

  class TeamWithExternalCarClassWithMoreAttributes < FormObj::Struct
    attribute :name
    attribute :car, class: CarWithMoreAttributes
  end

  def test_class_comparison_with_another_class_with_external_car_class_with_more_attributes
    assert(Team.eql? TeamWithExternalCarClassWithMoreAttributes)
    refute(Team.eql? TeamWithExternalCarClassWithMoreAttributes.new)

    assert(Team === TeamWithExternalCarClassWithMoreAttributes)
    assert(Team === TeamWithExternalCarClassWithMoreAttributes.new)

    assert(Team == TeamWithExternalCarClassWithMoreAttributes)
    refute(Team == TeamWithExternalCarClassWithMoreAttributes.new)
  end

  def test_class_comparison_with_another_class_with_external_car_class_with_less_attributes
    refute(TeamWithExternalCarClassWithMoreAttributes.eql? Team)
    refute(TeamWithExternalCarClassWithMoreAttributes.eql? Team.new)

    refute(TeamWithExternalCarClassWithMoreAttributes === Team)
    refute(TeamWithExternalCarClassWithMoreAttributes === Team.new)

    refute(TeamWithExternalCarClassWithMoreAttributes == Team)
    refute(TeamWithExternalCarClassWithMoreAttributes == Team.new)
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




  class InheritedTeamWithExternalCarClass < Team
    attribute :car, class: Car
  end

  def test_class_comparison_with_inherited_class
    assert(Team.eql? InheritedTeam)
    refute(Team.eql? InheritedTeam.new)

    assert(Team === InheritedTeam)
    assert(Team === InheritedTeam.new)

    assert(Team == InheritedTeam)
    refute(Team == InheritedTeam.new)
  end




  class InheritedTeamWithExternalCarClassWithAnotherPrimaryKey < Team
    attribute :car, class: CarWithAnotherPrimaryKey
  end




  class InheritedTeamWithExternalCarClassWithAnotherDefaultValue < Team
    attribute :car, class: CarWithAnotherDefaultValue
  end




  class InheritedTeamWithExternalCarClassWithArray < Team
    attribute :car, array: true, class: Car
  end




  class InheritedTeamWithExternalCarClassWithMoreAttributes < Team
    attribute :car, class: CarWithMoreAttributes
  end




  AnotherTeam = Struct.new(:id, :car)

  def test_class_comparison_with_non_form_object_class
    refute(Team.eql? AnotherTeam)
    refute(Team.eql? AnotherTeam.new)

    refute(Team === AnotherTeam)
    refute(Team === AnotherTeam.new)

    refute(Team == AnotherTeam)
    refute(Team == AnotherTeam.new)
  end
end
