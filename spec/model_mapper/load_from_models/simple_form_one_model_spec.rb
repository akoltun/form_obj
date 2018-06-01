RSpec.describe 'load_from_model: Simple Form Object - One Model' do

  let(:model) { Struct.new(:team_name, :year, :month, :car).new('Ferrari', 1950, 'April', { engine: Struct.new(:power).new(335) }) }

  module LoadFromModel
    class SimpleForm < FormObj::Form
      include FormObj::ModelMapper

      attribute :name, model_attribute: :team_name
      attribute :year
      attribute :month, model_attribute: false
      attribute :day, model_attribute: false
      attribute :engine_power, model_attribute: 'car.:engine.power'
    end
  end

  let(:form) { LoadFromModel::SimpleForm.new }

  it 'has all attributes correctly set up' do
    form.load_from_model(model)

    expect(form.name).to eq model.team_name
    expect(form.year).to eq model.year
    expect(form.month).to be_nil
    expect(form.day).to be_nil                                  # will not raise error if attribute is not existent in the model
    expect(form.engine_power).to eq model.car[:engine].power
  end

  it 'returns self' do
    expect(form.load_from_model(model)).to eql form
  end
end
