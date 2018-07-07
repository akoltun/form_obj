require "test_helper"

class ModelMapperCopyErrorsFromModelsTest < Minitest::Test
  EngineModel = Struct.new(:power, :errors)
  TeamModel = Struct.new(:team_name, :year, :errors)

  class Team < FormObj::Form
    include FormObj::ModelMapper

    attribute :name, model_attribute: :team_name
    attribute :year
    attribute :engine_power, model: :car, model_attribute: ':engine.power'
  end

  def setup
    @team_model = TeamModel.new('Ferrari', 1950, { team_name: ['too long', 'not nice'], year: ['not a number']})
    @car_model = { engine: EngineModel.new(335, { power: ['too low', 'in wrong units'] }) }

    @team = Team.new
  end

  def test_that_it_returns_form_itself
    assert_same(@team, @team.copy_errors_from_models(default: @team_model, car: @car_model))
  end

  def test_that_it_copies_errors_from_models
    @team.copy_errors_from_models(default: @team_model, car: @car_model)

    assert_equal(['too long', 'not nice'],      @team.errors[:name])
    assert_equal(['not a number'],              @team.errors[:year])
    assert_equal(['too low', 'in wrong units'], @team.errors[:engine_power])
  end
end
