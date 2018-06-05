RSpec.describe 'initialize attributes: Simple Struct' do
  module InitializeAttributes
    class SimpleStruct < FormObj::Struct
      attribute :name
      attribute :year
    end
  end

  let(:hash) {{name: 'Ferrari', year: 1950}}
  let(:struct) { InitializeAttributes::SimpleStruct.new(hash) }

  it 'has assigned values' do
    expect(struct.name).to eq 'Ferrari'
    expect(struct.year).to eq 1950
  end

  it "doesn't have another attributes" do
    expect {
      struct.another_attribute
    }.to raise_error NoMethodError
  end

  context 'initialize non-existent attribute' do
    let(:hash) {{a: 1}}

    context 'when called without parameter' do
      it 'raises' do
        expect{
          struct
        }.to raise_error FormObj::UnknownAttributeError, 'a'
      end
    end

    context 'when called with raise_if_not_found parameter' do
      let(:struct) { InitializeAttributes::SimpleStruct.new(hash, opts) }

      context 'when called with raise_if_not_found = true' do
        let(:opts) {{ raise_if_not_found: true }}

        it 'raises' do
          expect{
            struct
          }.to raise_error FormObj::UnknownAttributeError, 'a'
        end
      end

      context 'when called with raise_if_not_found = false' do
        let(:opts) {{ raise_if_not_found: false }}

        it 'does not raise' do
          expect{
            struct
          }.not_to raise_error
        end

        it 'does not create new attribute' do
          expect{
            struct.a
          }.to raise_error NoMethodError
        end
      end
    end
  end
end