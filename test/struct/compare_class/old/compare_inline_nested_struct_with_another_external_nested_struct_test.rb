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
end
