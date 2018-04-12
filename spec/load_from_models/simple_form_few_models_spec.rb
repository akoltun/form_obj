RSpec.describe FormObj, concept: true do
  describe 'LoadFromModel: simple form - few models' do

    let(:car) {{ engine: Struct.new(:power).new(335) }}
    let(:team) { Struct.new(:team_name, :year).new('Ferrari', 1950) }

    context 'without default model' do
      module LoadFromModel
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
      let(:form) { LoadFromModel::SimpleForm::FewModels::Form.new(team: team, car: car) }

      it 'has all attributes correctly set up' do
        expect(form.name).to eq team.team_name
        expect(form.year).to eq team.year
        expect(form.engine_power).to eq car[:engine].power
      end

      it 'returns self' do
        expect(form.load_from_models(team: team, car: car)).to eql form
      end
    end

    context 'with default model' do
      module LoadFromModel
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
      let(:form) { LoadFromModel::SimpleForm::FewModelsWithDefault::Form.new(default: team, car: car) }

      it 'has all attributes correctly set up' do
        expect(form.name).to eq team.team_name
        expect(form.year).to eq team.year
        expect(form.engine_power).to eq car[:engine].power
      end

      it 'returns self' do
        expect(form.load_from_models(default: team, car: car)).to eql form
      end
    end
  end
end