RSpec.describe FormObj, concept: true do
  describe 'to_model_hash: simple form - one model' do
    subject { form.to_model_hash }

    module SaveToModel
      module SimpleForm
        module OneModel
          Engine = Struct.new(:power)

          class Form < FormObj
            attribute :name, model_attribute: :team_name
            attribute :year
            attribute :engine_power, model_attribute: 'car.:engine.power', model_class: [Hash, Engine]
          end
        end
      end
    end

    let(:engine) { SaveToModel::SimpleForm::OneModel::Engine.new }
    let(:model) { Struct.new(:team_name, :year, :car).new }
    let(:form) { SaveToModel::SimpleForm::OneModel::Form.new() }

    context 'nested models are created when they do not exist yet' do
      before do
        form.name = 'Ferrari'
        form.year = 1950
        form.engine_power = 335

        form.save_to_models(default: model)
      end

      it 'has all attributes correctly saved' do
        expect(model.team_name).to          eq form.name
        expect(model.year).to               eq form.year
        expect(model.car[:engine].power).to eq form.engine_power
      end
    end

    context 'missing nested models are created when they do not exist yet' do
      let(:car) { {} }

      before do
        model.car = car

        form.name = 'Ferrari'
        form.year = 1950
        form.engine_power = 335

        form.save_to_model(model)
      end

      it 'has all attributes correctly saved' do
        expect(model.team_name).to          eq form.name
        expect(model.year).to               eq form.year
        expect(model.car[:engine].power).to eq form.engine_power
      end

      it "doesn't create existing nested models" do
        expect(model.car).to eql car
      end
    end

    context 'nested models are updated when they exists already' do
      let(:car) {{ engine: engine }}
      before do
        model.car = car

        form.name = 'Ferrari'
        form.year = 1950
        form.engine_power = 335

        form.save_to_model(model)
      end

      it 'has all attributes correctly saved' do
        expect(model.team_name).to          eq form.name
        expect(model.year).to               eq form.year
        expect(model.car[:engine].power).to eq form.engine_power
      end

      it "doesn't create existing nested models" do
        expect(model.car).to eql car
        expect(model.car[:engine]).to eql engine
      end
    end
  end
end