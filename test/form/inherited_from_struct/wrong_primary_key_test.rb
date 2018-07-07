require "test_helper"

class WrongPrimaryKeyTest < Minitest::Test
  def test_that_error_is_raised_when_default_primary_key_does_not_exists
    assert_equal('(driver) has no attribute :id which is specified/defaulted as primary key',
                 assert_raises(::FormObj::NonexistentPrimaryKeyError) do
                   Class.new(FormObj::Form) do
                     attribute :cars, array: true do
                       attribute :driver
                     end
                   end
                 end.message
    )
  end

  def test_that_error_is_raised_when_specified_primary_key_does_not_exists
    assert_equal('(driver) has no attribute :non_existent which is specified/defaulted as primary key',
                 assert_raises(::FormObj::NonexistentPrimaryKeyError) do
                   Class.new(FormObj::Form) do
                     attribute :cars, array: true, primary_key: :non_existent do
                       attribute :driver
                     end
                   end
                 end.message
    )
  end
end
