RSpec.describe 'copy_errors_from_model: Simple Form Object - One Model' do
  let(:model) { Struct.new(:team_name, :year, :month, :car, :errors).new('Ferrari', 1950, 'April', { engine: Struct.new(:power, :errors).new(335, { power: ['too low', 'in wrong units'] }) }, { team_name: ['too long', 'not nice'], year: ['not a number']}) }

  module CopyErrorsFromModel
    class SimpleForm < FormObj::Form
      include FormObj::Mappable

      attribute :name, model_attribute: :team_name
      attribute :year
      attribute :month, model_attribute: false
      attribute :engine_power, model_attribute: 'car.:engine.power'
    end
  end

  let(:form) { CopyErrorsFromModel::SimpleForm.new.load_from_model(model) }

  it 'has all errors copied correctly' do
    form.copy_errors_from_model(model)

    expect(form.errors.messages).to eq Hash[
                                           name: ['too long', 'not nice'],
                                           year: ['not a number'],
                                           engine_power: ['too low', 'in wrong units']
                                       ]
  end

  it 'returns self' do
    expect(form.copy_errors_from_model(model)).to eql form
  end
end