RSpec.describe 'Simple TreeStruct' do
  class SimpleTreeStruct < TreeStruct
    attribute :name
    attribute :year
  end

  let(:tree_struct) { SimpleTreeStruct.new }
  before do
    tree_struct.name = 'Ferrari'
    tree_struct.year = 1950
  end

  it 'has assigned values' do
    expect(tree_struct.name).to eq 'Ferrari'
    expect(tree_struct.year).to eq 1950
  end

  it "doesn't have another attributes" do
    expect {
      tree_struct.another_attribute
    }.to raise_error NoMethodError
  end
end