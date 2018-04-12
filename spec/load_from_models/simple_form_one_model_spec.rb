RSpec.describe FormObj, concept: true do
  describe 'LoadFromModel: simple form - one model' do

    let(:model) { Struct.new(:team_name, :year, :car).new('Ferrari', 1950, { engine: Struct.new(:power).new(335) }) }

    module LoadFromModel
      module SimpleForm
        module OneModel
          class Form < FormObj
            attribute :name, model_attribute: :team_name
            attribute :year
            attribute :engine_power, model_attribute: 'car.:engine.power'
          end
        end
      end
    end

    let(:form) { LoadFromModel::SimpleForm::OneModel::Form.new(default: model) }

    it 'has all attributes correctly set up' do
      expect(form.name).to eq model.team_name
      expect(form.year).to eq model.year
      expect(form.engine_power).to eq model.car[:engine].power
    end

    it 'returns self' do
      expect(form.load_from_model(model)).to eql form
    end
  end
end