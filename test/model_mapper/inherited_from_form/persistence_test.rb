require "test_helper"

class ModelMapperPersistenceTest < Minitest::Test
  class Team < FormObj::Form
    include FormObj::ModelMapper

    attribute :name
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver

    end
    attribute :colour do
      attribute :rgb
    end
  end

  class DefaultTeam < FormObj::Form
    include FormObj::ModelMapper

    attribute :name, default: 'Ferrari'
    attribute :cars, array: true, default: [{code: '1'}, {code: '2'}], primary_key: :code do
      attribute :code
      attribute :driver
    end
    attribute :colour do
      attribute :rgb, default: 0xFFFFFF
    end
  end

  def test_that_form_is_not_persisted_after_initialization_without_initial_parameters
    team = Team.new
    refute(team.persisted?)
    refute(team.colour.persisted?)
    assert(team.cars.persisted?)
  end

  def test_that_form_is_not_persisted_after_initialization_with_initial_parameters
    team = Team.new(name: 'Ferrari')
    refute(team.persisted?)
    refute(team.colour.persisted?)
    assert(team.cars.persisted?)
  end

  def test_that_form_is_not_persisted_after_initialization_with_initial_parameters_for_nested_form
    team = Team.new(colour: { rgb: 0xFFFFFF } )
    refute(team.persisted?)
    refute(team.colour.persisted?)
    assert(team.cars.persisted?)
  end

  def test_that_form_is_not_persisted_after_initialization_with_initial_parameters_for_empty_nested_array
    team = Team.new(cars: [])
    refute(team.persisted?)
    refute(team.colour.persisted?)
    assert(team.cars.persisted?)
  end

  def test_that_form_is_not_persisted_after_initialization_with_initial_parameters_for_non_empty_nested_array
    team = Team.new(cars: [{code: '1'}, {code: '2'}])
    refute(team.persisted?)
    refute(team.colour.persisted?)
    refute(team.cars.persisted?)
    refute(team.cars[0].persisted?)
    refute(team.cars[1].persisted?)
  end

  def test_that_form_is_not_persisted_after_initialization_with_default_values
    team = DefaultTeam.new
    refute(team.persisted?)
    refute(team.colour.persisted?)
    refute(team.cars.persisted?)
    refute(team.cars[0].persisted?)
    refute(team.cars[1].persisted?)
  end

  def test_that_mark_as_persisted_returns_object_itself
    team = Team.new
    assert_same(team, team.mark_as_persisted)
  end

  def test_that_form_becomes_persisted_after_marking_as_persisted
    team = DefaultTeam.new.mark_as_persisted

    assert(team.persisted?)
    assert(team.colour.persisted?)
    assert(team.cars.persisted?)
    assert(team.cars[0].persisted?)
    assert(team.cars[1].persisted?)
  end

  def test_that_persisted_form_remains_persisted_after_updating_attribute
    team = DefaultTeam.new.mark_as_persisted

    team.name = 'McLaren'
    assert(team.persisted?)
    assert(team.colour.persisted?)
    assert(team.cars.persisted?)
    assert(team.cars[0].persisted?)
    assert(team.cars[1].persisted?)
  end

  def test_that_persisted_form_remains_persisted_after_updating_nested_attribute
    team = DefaultTeam.new.mark_as_persisted

    team.colour.rgb = 0xFFFFFF
    assert(team.persisted?)
    assert(team.colour.persisted?)
    assert(team.cars.persisted?)
    assert(team.cars[0].persisted?)
    assert(team.cars[1].persisted?)
  end

  def test_that_persisted_form_remains_persisted_after_updating_attribute_of_element_in_the_array
    team = DefaultTeam.new.mark_as_persisted

    team.cars[0].driver = 'Ascari'
    assert(team.persisted?)
    assert(team.colour.persisted?)
    assert(team.cars.persisted?)
    assert(team.cars[0].persisted?)
    assert(team.cars[1].persisted?)
  end

  def test_that_persisted_form_remains_persisted_after_adding_element_to_array
    team = DefaultTeam.new.mark_as_persisted

    team.cars.build
    assert(team.persisted?)
    assert(team.colour.persisted?)
    refute(team.cars.persisted?)
    assert(team.cars[0].persisted?)
    assert(team.cars[1].persisted?)
    refute(team.cars[2].persisted?)
  end

  def test_that_persisted_form_remains_persisted_after_marking_element_for_destruction
    team = DefaultTeam.new.mark_as_persisted

    team.cars[1].mark_for_destruction
    assert(team.persisted?)
    assert(team.colour.persisted?)
    assert(team.cars.persisted?)
    assert(team.cars[0].persisted?)
    assert(team.cars[1].persisted?)
  end
end
