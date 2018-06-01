RSpec.describe 'load_from_models: Simple Form Object - Few Models' do

  let(:car) {{ engine: Struct.new(:power).new(335) }}
  let(:team) { Struct.new(:team_name, :year).new('Ferrari', 1950) }

  context 'without default model' do
    module LoadFromModels
      class SimpleForm < FormObj::Form
        include FormObj::ModelMapper

        attribute :name, model_attribute: :team_name, model: :team
        attribute :year, model: :team
        attribute :engine_power, model: :car, model_attribute: ':engine.power'
      end
    end
    let(:form) { LoadFromModels::SimpleForm.new }

    it 'has all attributes correctly set up' do
      form.load_from_models(team: team, car: car)

      expect(form.name).to eq team.team_name
      expect(form.year).to eq team.year
      expect(form.engine_power).to eq car[:engine].power
    end

    it 'returns self' do
      expect(form.load_from_models(team: team, car: car)).to eql form
    end
  end

  context 'with default model' do
    module LoadFromModelsWithDefault
      class SimpleForm < FormObj::Form
        include FormObj::ModelMapper

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :engine_power, model: :car, model_attribute: ':engine.power'
      end
    end
    let(:form) { LoadFromModelsWithDefault::SimpleForm.new }

    it 'has all attributes correctly set up' do
      form.load_from_models(default: team, car: car)

      expect(form.name).to eq team.team_name
      expect(form.year).to eq team.year
      expect(form.engine_power).to eq car[:engine].power
    end

    it 'returns self' do
      expect(form.load_from_models(default: team, car: car)).to eql form
    end
  end
end
