require "test_helper"

class ModelMapperCopyErrorsFromModelTest < Minitest::Test
  EngineModel = Struct.new(:power, :errors)
  TeamModel = Struct.new(:team_name, :year, :month, :car, :errors)

  class Team < FormObj::Form
    include FormObj::ModelMapper

    attribute :name, model_attribute: :team_name
    attribute :year
    attribute :month, model_attribute: false
    attribute :engine_power, model_attribute: 'car.:engine.power'
  end

  def setup
    @team_model = TeamModel.new(
        'Ferrari',
        1950,
        'April',
        { engine: EngineModel.new(335, { power: ['too low', 'in wrong units'] }) },
        { team_name: ['too long', 'not nice'], year: ['not a number'], month: ['wrong month']}
    )

    @team = Team.new
  end

  def test_that_it_returns_form_itself
    assert_same(@team, @team.copy_errors_from_model(@team_model))
  end

  def test_that_it_copies_errors_from_model
    @team.copy_errors_from_model(@team_model)

    assert_equal(['too long', 'not nice'],      @team.errors[:name])
    assert_equal(['not a number'],              @team.errors[:year])
    assert_equal(['too low', 'in wrong units'], @team.errors[:engine_power])
    refute(@team.errors.include? :month)
  end
end
