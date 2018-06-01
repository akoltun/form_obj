RSpec.describe 'duplicate attribute: Array of Struct' do
  module DuplicateAttribute
    class ArrayStruct < FormObj::Struct
      attribute :name
      attribute :year
      attribute :cars, array: true do
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

  let(:struct) { DuplicateAttribute::ArrayStruct.new }
  before do
    struct.cars.create
    struct.cars.create
  end

  it 'has only one attribute :code and one attribute :engine' do
    expect(struct.cars[0].class.attributes.size).to eq 3
    expect(struct.cars[0].class.attributes).to match_array %i{code driver engine}

    expect(struct.cars[1].class.attributes.size).to eq 3
    expect(struct.cars[1].class.attributes).to match_array %i{code driver engine}
  end

  it 'attribute :engine is not nested' do
    expect {
      struct.cars[0].engine.power = 335
    }.to raise_error NoMethodError

    expect {
      struct.cars[1].engine.power = 335
    }.to raise_error NoMethodError
  end
end