RSpec.describe 'to_hash: Simple Struct' do
  module ToHash
    class SimpleStruct < FormObj::Struct
      attribute :name
      attribute :year
    end
  end

  let(:struct) { ToHash::SimpleStruct.new }
  before do
    struct.name = 'Ferrari'
    struct.year = 1950
  end

  subject { struct.to_hash }

  it 'correctly presents all attributes in the hash' do
    is_expected.to eq Hash[
                          name: 'Ferrari',
                          year: 1950
                      ]
  end
end