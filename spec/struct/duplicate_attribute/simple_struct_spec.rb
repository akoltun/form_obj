RSpec.describe 'duplicate attribute: Simple Struct' do
  module DuplicateAttribute
    class SimpleStruct < FormObj::Struct
      attribute :name
      attribute :year
      attribute :name
    end
  end

  it 'has only one attribute :name' do
    expect(DuplicateAttribute::SimpleStruct.attributes.size).to eq 2
    expect(DuplicateAttribute::SimpleStruct.attributes).to match_array %i{name year}
  end
end