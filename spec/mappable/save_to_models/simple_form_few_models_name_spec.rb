RSpec.describe 'save_to_models: Simple Form Object - Few Models - Name' do
  let(:team) { Struct.new(:team_name, :year).new }
  let(:car) { {} }

  before do
    form.name = 'Ferrari'
    form.year = 1950
    form.engine_power = 335
  end

  context 'without default model' do
    module SaveToModels
      class SimpleFormName < FormObj::Form
        Engine = Struct.new(:power)

        include FormObj::Mappable

        attribute :name, model_attribute: :team_name, model: :team
        attribute :year, model: :team
        attribute :engine_power, model: :car, model_attribute: ':engine.power', model_class: 'SaveToModels::SimpleFormName::Engine'
      end
    end
    let(:form) { SaveToModels::SimpleFormName.new }

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
    module SaveToModelsWithDefault
      class SimpleFormName < FormObj::Form
        Engine = Struct.new(:power)

        include FormObj::Mappable

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :engine_power, model: :car, model_attribute: ':engine.power', model_class: 'SaveToModelsWithDefault::SimpleFormName::Engine'
      end
    end
    let(:form) { SaveToModelsWithDefault::SimpleFormName.new }

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
