RSpec.describe 'to_hash: Simple Form Object' do
  module ToHash
    class SimpleForm < FormObj
      attribute :name
      attribute :year
    end
  end

  let(:form) { ToHash::SimpleForm.new }
  before do
    form.name = 'Ferrari'
    form.year = 1950
  end

  subject { form.to_hash }

  it 'correctly presents all attributes in the hash' do
    is_expected.to eq Hash[
                          name: 'Ferrari',
                          year: 1950
                      ]
  end
end