RSpec.describe FormObj, concept: true do
  describe 'SaveToModel: simple form - few models - name' do
    let(:team) { Struct.new(:team_name, :year).new }
    let(:car) { {} }

    module SaveToModel
      module SimpleForm
        module FewModelsName
          Engine = Struct.new(:power)
        end
      end
    end

    before do
      form.name = 'Ferrari'
      form.year = 1950
      form.engine_power = 335
    end

    context 'without default model' do
      module SaveToModel
        module SimpleForm
          module FewModelsName
            class Form < FormObj
              attribute :name, model_attribute: :team_name, model: :team
              attribute :year, model: :team
              attribute :engine_power, model: :car, model_attribute: ':engine.power', model_class: 'SaveToModel::SimpleForm::FewModelsName::Engine'
            end
          end
        end
      end
      let(:form) { SaveToModel::SimpleForm::FewModelsName::Form.new }

      context 'nested models are created when they do not exist yet' do
        it 'has all attributes correctly saved' do
          form.save_to_models(team: team, car: car)

          expect(team.team_name).to     eq form.name
          expect(team.year).to          eq form.year
          expect(car[:engine].power).to eq form.engine_power
        end

        it 'returns self' do
          expect(form.save_to_models(team: team, car: car)).to eql form
        end
      end

      context 'nested models are updated when they exists already' do
        let(:car) {{ engine: Struct.new(:power).new }}

        it 'has all attributes correctly saved' do
          form.save_to_models(team: team, car: car)

          expect(team.team_name).to     eq form.name
          expect(team.year).to          eq form.year
          expect(car[:engine].power).to eq form.engine_power
        end

        it 'returns self' do
          expect(form.save_to_models(team: team, car: car)).to eql form
        end
      end
    end

    context 'with default model' do
      module SaveToModel
        module SimpleForm
          module FewModelsNameWithDefault
            class Form < FormObj
              attribute :name, model_attribute: :team_name
              attribute :year
              attribute :engine_power, model: :car, model_attribute: ':engine.power', model_class: 'SaveToModel::SimpleForm::FewModelsName::Engine'
            end
          end
        end
      end
      let(:form) { SaveToModel::SimpleForm::FewModelsNameWithDefault::Form.new }

      context 'nested models are created when they do not exist yet' do
        it 'has all attributes correctly saved' do
          form.save_to_models(default: team, car: car)

          expect(team.team_name).to     eq form.name
          expect(team.year).to          eq form.year
          expect(car[:engine].power).to eq form.engine_power
        end

        it 'returns self' do
          expect(form.save_to_models(default: team, car: car)).to eql form
        end
      end

      context 'nested models are updated when they exists already' do
        let(:car) {{ engine: Struct.new(:power).new }}

        it 'has all attributes correctly saved' do
          form.save_to_models(default: team, car: car)

          expect(team.team_name).to     eq form.name
          expect(team.year).to          eq form.year
          expect(car[:engine].power).to eq form.engine_power
        end

        it 'returns self' do
          expect(form.save_to_models(default: team, car: car)).to eql form
        end
      end
    end
  end
end