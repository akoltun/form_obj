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
  end

  let(:hash) {{ name: 'McLaren', year: 1966 }}
  let(:update_attributes) { struct.update_attributes(hash) }

  it 'has all attributes correctly updated' do
    update_attributes

    expect(struct.name).to eq 'McLaren'
    expect(struct.year).to eq 1966
  end

  it 'returns self' do
    expect(update_attributes).to eql struct
  end

  context 'update non-existent attribute' do
    let(:hash) {{a: 1}}

    context 'when called without parameter' do
      it 'raises' do
        expect{
          update_attributes
        }.to raise_error FormObj::UnknownAttributeError, 'a'
      end
    end

    context 'when called with raise_if_not_found parameter' do
      let(:update_attributes) { struct.update_attributes(hash, opts) }

      context 'when called with raise_if_not_found = true' do
        let(:opts) {{ raise_if_not_found: true }}

        it 'raises' do
          expect{
            update_attributes
          }.to raise_error FormObj::UnknownAttributeError, 'a'
        end
      end

      context 'when called with raise_if_not_found = false' do
        let(:opts) {{ raise_if_not_found: false }}

        it 'does not raise' do
          expect{
            update_attributes
          }.not_to raise_error
        end

        it 'does not create new attribute' do
          expect{
            update_attributes.a
          }.to raise_error NoMethodError
        end
      end
    end
  end
end
