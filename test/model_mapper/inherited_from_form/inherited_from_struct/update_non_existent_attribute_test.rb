require "test_helper"

class ModelMapperUpdateNonExistentAttributeTest < Minitest::Test
  class Chassis < FormObj::Form
    include FormObj::ModelMapper

    attribute :brakes
  end
  class Team < FormObj::Form
    include FormObj::ModelMapper

    attribute :name
    attribute :cars, array: true do
      attribute :code, primary_key: true
      attribute :driver
      attribute :chassis, class: 'ModelMapperUpdateNonExistentAttributeTest::Chassis'
    end
  end

  def setup
    @team = Team.new(
        name: 'McLaren',
        cars: [{
                   code: '275 F1',
                   driver: 'Villoresi',
                   chassis: {
                       brakes: :disc,
                   }
               }],
    )
  end

  def test_that_error_is_raised_when_try_to_update_non_existent_attribute
    assert_raises(FormObj::UnknownAttributeError) { @team.update_attributes(a: 1) }

    assert_raises(FormObj::UnknownAttributeError) { @team.update_attributes(cars: [{a: 1}]) }

    assert_raises(FormObj::UnknownAttributeError) { @team.update_attributes(cars: [{chassis: {a: 1}}]) }
  end

  def test_that_error_is_raised_when_try_to_update_non_existent_attribute_with_parameter_raise_if_not_found_equal_to_true
    assert_raises(FormObj::UnknownAttributeError) { @team.update_attributes({a: 1}, raise_if_not_found: true) }

    assert_raises(FormObj::UnknownAttributeError) { @team.update_attributes({cars: [{a: 1}]}, raise_if_not_found: true) }

    assert_raises(FormObj::UnknownAttributeError) { @team.update_attributes({cars: [{chassis: {a: 1}}]}, raise_if_not_found: true) }
  end

  def test_that_non_existent_attribute_is_ignored_when_try_to_update_it_with_parameter_raise_if_not_found_equal_to_false
    assert_same(@team, @team.update_attributes({
                                                   name: 'Ferrari',
                                                   a: 1,
                                                   cars: [{
                                                              code: '275 F1',
                                                              b: 2,
                                                              chassis: {
                                                                  brakes: :drum,
                                                                  c: 3
                                                              }
                                                          }],
                                               }, raise_if_not_found: false))

    assert_equal('Ferrari', @team.name)

    assert_equal(1, @team.cars.size)

    assert_equal('275 F1',    @team.cars[0].code)
    assert_equal('Villoresi', @team.cars[0].driver)
    assert_equal(:drum,       @team.cars[0].chassis.brakes)

    assert_raises(NoMethodError) { @team.a }
    assert_raises(NoMethodError) { @team.cars[0].b }
    assert_raises(NoMethodError) { @team.cars[0].chassis.c }
  end
end
