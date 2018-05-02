RSpec.describe 'to_hash: Simple TreeStruct' do
  module ToHash
    class SimpleTreeStruct < TreeStruct
      attribute :name
      attribute :year
    end
  end

  let(:tree_struct) { ToHash::SimpleTreeStruct.new }
  before do
    tree_struct.name = 'Ferrari'
    tree_struct.year = 1950
  end

  subject { tree_struct.to_hash }

  it 'correctly presents all attributes in the hash' do
    is_expected.to eq Hash[
                          name: 'Ferrari',
                          year: 1950
                      ]
  end
end