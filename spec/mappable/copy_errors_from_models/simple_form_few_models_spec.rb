RSpec.describe 'copy_errors_from_models: Simple Form Object - Few Models' do

  let(:car) {{ engine: Struct.new(:power, :errors).new(335, { power: ['too low', 'in wrong units'] }) }}
  let(:team) { Struct.new(:team_name, :year, :errors).new('Ferrari', 1950, { team_name: ['too long', 'not nice'], year: ['not a number']}) }

  context 'without default model' do
    module CopyErrorsFromModels
      class SimpleForm < FormObj::Form
        include FormObj::Mappable

        attribute :name, model_attribute: :team_name, model: :team
        attribute :year, model: :team
        attribute :engine_power, model: :car, model_attribute: ':engine.power'
      end
    end
    let(:form) { CopyErrorsFromModels::SimpleForm.new.load_from_models(team: team, car: car) }

    it 'has all errors copied correctly' do
      form.copy_errors_from_models(team: team, car: car)

      expect(form.errors[:name]).to match_array(['too long', 'not nice'])
      expect(form.errors[:year]).to match_array(['not a number'])
      expect(form.errors[:engine_power]).to match_array(['too low', 'in wrong units'])
    end

    it 'returns self' do
      expect(form.copy_errors_from_models(team: team, car: car)).to eql form
    end
  end

  context 'with default model' do
    module CopyErrorsFromModelsWithDefault
      class SimpleForm < FormObj::Form
        include FormObj::Mappable

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :engine_power, model: :car, model_attribute: ':engine.power'
      end
    end
    let(:form) { CopyErrorsFromModelsWithDefault::SimpleForm.new.load_from_models(default: team, car: car) }

    it 'has all errors copied correctly' do
      form.copy_errors_from_models(default: team, car: car)

      expect(form.errors[:name]).to match_array(['too long', 'not nice'])
      expect(form.errors[:year]).to match_array(['not a number'])
      expect(form.errors[:engine_power]).to match_array(['too low', 'in wrong units'])
    end

    it 'returns self' do
      expect(form.copy_errors_from_models(default: team, car: car)).to eql form
    end
  end
end
