RSpec.describe 'to_model_hash: Simple Form Object - Few Models' do
  module ToModelHash
    module FewModels
      class SimpleForm < FormObj
        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :engine_power, model: :car, model_attribute: ':engine.power'
      end
    end
  end

  let(:form) { ToModelHash::FewModels::SimpleForm.new }

  before do
    form.name = 'Ferrari'
    form.year = 1950
    form.engine_power = 335
  end

  it 'correctly presents all attributes in the hash' do
    expect(form.to_model_hash).to eq Hash[
                                         team_name: 'Ferrari',
                                         year: 1950,
                                     ]

    expect(form.to_model_hash(:car)).to eq Hash[
                                                   engine: {
                                                       power: 335
                                                   }
                                               ]
  end
end