require "test_helper"

class ModelMapperMarkForDestructionTest < Minitest::Test
  class Team < FormObj::Form
    include FormObj::ModelMapper

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
  end

  def test_that_form_is_not_marked_for_destruction_after_initialization
    refute(@team.marked_for_destruction?)
    refute(@team.colour.marked_for_destruction?)
    assert_raises(NoMethodError) { @team.cars.marked_for_destruction? }
    refute(@team.cars[0].marked_for_destruction?)
    refute(@team.cars[1].marked_for_destruction?)
  end

  def test_that_mark_for_destruction_returns_object_itself
    assert_same(@team, @team.mark_for_destruction)
  end

  def test_that_mark_for_destruction_only_array_element_will_mark_only_it
    @team.cars[0].mark_for_destruction

    refute(@team.marked_for_destruction?)
    refute(@team.colour.marked_for_destruction?)
    assert_raises(NoMethodError) { @team.cars.marked_for_destruction? }
    assert(@team.cars[0].marked_for_destruction?)
    refute(@team.cars[1].marked_for_destruction?)
  end

  def test_that_mark_for_destruction_only_nested_form_will_mark_only_it
    @team.colour.mark_for_destruction

    refute(@team.marked_for_destruction?)
    assert(@team.colour.marked_for_destruction?)
    assert_raises(NoMethodError) { @team.cars.marked_for_destruction? }
    refute(@team.cars[0].marked_for_destruction?)
    refute(@team.cars[1].marked_for_destruction?)
  end

  def test_that_mark_for_destruction_the_root_form_will_also_mark_all_nested_forms
    @team.mark_for_destruction

    assert(@team.marked_for_destruction?)
    assert(@team.colour.marked_for_destruction?)
    assert_raises(NoMethodError) { @team.cars.marked_for_destruction? }
    assert(@team.cars[0].marked_for_destruction?)
    assert(@team.cars[1].marked_for_destruction?)
  end
end
