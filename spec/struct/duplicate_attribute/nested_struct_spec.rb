RSpec.describe 'duplicate attribute: Nested Struct' do
  module DuplicateAttribute
    class NestedStruct < FormObj::Struct
      attribute :name
      attribute :year
      attribute :car do
        attribute :code
        attribute :driver
        attribute :engine do
          attribute :power
          attribute :volume
        end
        attribute :engine
        attribute :code
      end
    end
  end

  let(:struct) { DuplicateAttribute::NestedStruct.new }

  it 'has only one attribute :code and one attribute :engine' do
    expect(struct.car.class.attributes.size).to eq 3
    expect(struct.car.class.attributes).to match_array %i{code driver engine}
  end

  it 'attribute :engine is not nested' do
    expect {
      struct.car.engine.power = 335
    }.to raise_error NoMethodError
  end
end