RSpec.describe 'copy_errors_from_model: Simple Form Object - One Model' do
  let(:model) { Struct.new(:team_name, :year, :car, :errors).new('Ferrari', 1950, { engine: Struct.new(:power, :errors).new(335, { power: ['too low', 'in wrong units'] }) }, { team_name: ['too long', 'not nice'], year: ['not a number']}) }

  module CopyErrorsFromModel
    class SimpleForm < FormObj::Form
      include FormObj::Mappable

      attribute :name, model_attribute: :team_name
      attribute :year
      attribute :engine_power, model_attribute: 'car.:engine.power'
    end
  end

  let(:form) { CopyErrorsFromModel::SimpleForm.new.load_from_model(model) }

  it 'has all errors copied correctly' do
    form.copy_errors_from_model(model)

    expect(form.errors[:name]).to match_array(['too long', 'not nice'])
    expect(form.errors[:year]).to match_array(['not a number'])
    expect(form.errors[:engine_power]).to match_array(['too low', 'in wrong units'])
  end

  it 'returns self' do
    expect(form.copy_errors_from_model(model)).to eql form
  end
end