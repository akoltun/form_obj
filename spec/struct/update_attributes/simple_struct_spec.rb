RSpec.describe 'update_attributes: Simple Struct' do
  module UpdateAttributes
    class SimpleStruct < FormObj::Struct
      attribute :name
      attribute :year
    end
  end

  let(:struct) { UpdateAttributes::SimpleStruct.new }
  before do
    struct.name = 'Ferrari'
    struct.year = 1950

    struct.update_attributes(name: 'McLaren', year: 1966)
  end

  it 'has all attributes correctly updated' do
    expect(struct.name).to eq 'McLaren'
    expect(struct.year).to eq 1966
  end

  it 'returns self' do
    expect(struct.update_attributes(name: 'McLaren', year: 1966)).to eql struct
  end
end
