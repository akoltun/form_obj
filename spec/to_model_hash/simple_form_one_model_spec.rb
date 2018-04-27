RSpec.describe 'to_model_hash: Simple Form Object - One Model' do
  subject { form.to_model_hash }

  module ToModelHash
    module OneModel
      class SimpleForm < FormObj
        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :engine_power, model_attribute: 'car.:engine.power'
      end
    end
  end

  let(:form) { ToModelHash::OneModel::SimpleForm.new }

  before do
    form.name = 'Ferrari'
    form.year = 1950
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