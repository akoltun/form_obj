RSpec.describe 'save_to_model: Simple Form Object - One Model' do
  module SaveToModel
    class SimpleForm < FormObj::Form
      Engine = Struct.new(:power)

      include FormObj::Mappable

      attribute :name, model_attribute: :team_name
      attribute :year
      attribute :engine_power, model_attribute: 'car.:engine.power', model_class: [Hash, Engine]
    end
  end

  let(:engine) { SaveToModel::SimpleForm::Engine.new }
  let(:model) { Struct.new(:team_name, :year, :car).new }
  let(:form) { SaveToModel::SimpleForm.new() }

  shared_context 'fill in a form' do
    before do
      form.name = 'Ferrari'
      form.year = 1950
      form.engine_power = 335
    end
  end

  shared_examples 'a form that can be saved' do
    it 'creates non-existent models and correctly saves all attributes' do
      expect(model.team_name).to          eq form.name
      expect(model.year).to               eq form.year
      expect(model.car[:engine].power).to eq form.engine_power
    end
  end

  context 'nested models do not exists' do
    include_context 'fill in a form'
    before { form.save_to_model(model) }

    it_behaves_like 'a form that can be saved'
  end

  context 'some of nested models do not exists' do
    let(:car) { {} }
    before { model.car = car }

    include_context 'fill in a form'
    before { form.save_to_model(model) }

    it_behaves_like 'a form that can be saved'
    it "doesn't create existing nested models" do
      expect(model.car).to eql car
    end
  end

  context 'all nested models exists' do
    let(:car) { { engine: engine } }
    before { model.car = car }

    include_context 'fill in a form'
    before { form.save_to_model(model) }

    it_behaves_like 'a form that can be saved'
    it "doesn't create existing nested models" do
      expect(model.car).to eql car
      expect(model.car[:engine]).to eql engine
    end
  end
end
