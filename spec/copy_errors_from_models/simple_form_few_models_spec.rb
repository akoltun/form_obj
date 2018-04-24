RSpec.describe FormObj, concept: true do
  describe 'CopyErrorsFromModels: simple form - few models' do

    let(:car) {{ engine: Struct.new(:power, :errors).new(335, { power: ['too low', 'in wrong units'] }) }}
    let(:team) { Struct.new(:team_name, :year, :errors).new('Ferrari', 1950, { team_name: ['too long', 'not nice'], year: ['not a number']}) }

    context 'without default model' do
      module CopyErrorsFromModels
        module SimpleForm
          module FewModels

            class Form < FormObj
              attribute :name, model_attribute: :team_name, model: :team
              attribute :year, model: :team
              attribute :engine_power, model: :car, model_attribute: ':engine.power'
            end
          end
        end
      end
      let(:form) { CopyErrorsFromModels::SimpleForm::FewModels::Form.new(team: team, car: car) }

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
      module CopyErrorsFromModels
        module SimpleForm
          module FewModelsWithDefault
            class Form < FormObj
              attribute :name, model_attribute: :team_name
              attribute :year
              attribute :engine_power, model: :car, model_attribute: ':engine.power'
            end
          end
        end
      end
      let(:form) { CopyErrorsFromModels::SimpleForm::FewModelsWithDefault::Form.new(default: team, car: car) }

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
end