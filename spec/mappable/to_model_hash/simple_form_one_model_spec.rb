RSpec.describe 'to_model_hash: Simple Form Object - One Model' do
  subject { form.to_model_hash }

  module ToModelHash
    class SimpleForm < FormObj::Form
      include FormObj::Mappable

      attribute :name, model_attribute: :team_name
      attribute :year
      attribute :month, model_attribute: false
      attribute :engine_power, model_attribute: 'car.:engine.power'
    end
  end

  let(:form) { ToModelHash::SimpleForm.new }

  before do
    form.name = 'Ferrari'
    form.year = 1950
    form.month = 'April'
    form.engine_power = 335
  end

  it 'correctly presents all attributes in the hash' do
    is_expected.to eq Hash[
                          team_name: 'Ferrari',
                          year: 1950,
                          car: {
                              engine: {
                                  power: 335
                              }
                          }
                      ]
  end
end