require "test_helper"

class FormPersistenceTest < Minitest::Test
  class Team < FormObj::Form
    attribute :name
    attribute :cars, array: true, default: [{code: '1'}, {code: '2'}], primary_key: :code do
      attribute :code
      attribute :driver

    end
    attribute :colour do
      attribute :rgb
    end
  end

  def setup
    @team = Team.new
    @team.mark_as_persisted
  end

  def test_that_form_is_not_persisted_after_initialization
    team = Team.new
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

  def test_that_form_is_persisted_after_setting_persisted_flag
    assert(@team.persisted?)
    assert(@team.colour.persisted?)
    assert(@team.cars.persisted?)
    assert(@team.cars[0].persisted?)
    assert(@team.cars[1].persisted?)
  end

  def test_that_persisted_form_becomes_non_persisted_after_updating_attribute
    @team.name = 'Ferrari'
    refute(@team.persisted?)
    assert(@team.colour.persisted?)
    assert(@team.cars.persisted?)
    assert(@team.cars[0].persisted?)
    assert(@team.cars[1].persisted?)
  end

  def test_that_persisted_form_becomes_non_persisted_after_updating_nested_attribute
    @team.colour.rgb = 0xFFFFFF
    refute(@team.persisted?)
    refute(@team.colour.persisted?)
    assert(@team.cars.persisted?)
    assert(@team.cars[0].persisted?)
    assert(@team.cars[1].persisted?)
  end

  def test_that_persisted_form_becomes_non_persisted_after_updating_attribute_of_element_in_the_array
    @team.cars[0].driver = 'Ascari'
    refute(@team.persisted?)
    assert(@team.colour.persisted?)
    refute(@team.cars.persisted?)
    refute(@team.cars[0].persisted?)
    assert(@team.cars[1].persisted?)
  end

  def test_that_persisted_form_becomes_non_persisted_after_adding_element_to_array
    @team.cars.build
    refute(@team.persisted?)
    assert(@team.colour.persisted?)
    refute(@team.cars.persisted?)
    assert(@team.cars[0].persisted?)
    assert(@team.cars[1].persisted?)
    refute(@team.cars[2].persisted?)
  end

  def test_that_persisted_form_becomes_non_persisted_after_marking_element_for_destruction
    @team.cars[1].mark_for_destruction
    refute(@team.persisted?)
    assert(@team.colour.persisted?)
    refute(@team.cars.persisted?)
    assert(@team.cars[0].persisted?)
    refute(@team.cars[1].persisted?)
  end
end
