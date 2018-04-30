RSpec.describe 'save_to_models: Simple Form Object - Few Models - Name' do
  let(:team) { Struct.new(:team_name, :year).new }
  let(:car) { {} }

  before do
    form.name = 'Ferrari'
    form.year = 1950
    form.engine_power = 335
  end

  context 'without default model' do
    module SaveToModel
      module FewModelsName
        class SimpleForm < FormObj
          Engine = Struct.new(:power)

          attribute :name, model_attribute: :team_name, model: :team
          attribute :year, model: :team
          attribute :engine_power, model: :car, model_attribute: ':engine.power', model_class: 'SaveToModel::FewModelsName::SimpleForm::Engine'
        end
      end
    end
    let(:form) { SaveToModel::FewModelsName::SimpleForm.new }

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
      module FewModelsNameWithDefault
        class SimpleForm < FormObj
          Engine = Struct.new(:power)

          attribute :name, model_attribute: :team_name
          attribute :year
          attribute :engine_power, model: :car, model_attribute: ':engine.power', model_class: 'SaveToModel::FewModelsNameWithDefault::SimpleForm::Engine'
        end
      end
    end
    let(:form) { SaveToModel::FewModelsNameWithDefault::SimpleForm.new }

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
