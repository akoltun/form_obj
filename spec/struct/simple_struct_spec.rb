RSpec.describe 'Simple Struct' do
  class SimpleStruct < FormObj::Struct
    attribute :name
    attribute :year
  end

  let(:struct) { SimpleStruct.new }
  before do
    struct.name = 'Ferrari'
    struct.year = 1950
  end

  it 'has assigned values' do
    expect(struct.name).to eq 'Ferrari'
    expect(struct.year).to eq 1950
  end

  it "doesn't have another attributes" do
    expect {
      struct.another_attribute
    }.to raise_error NoMethodError
  end
end