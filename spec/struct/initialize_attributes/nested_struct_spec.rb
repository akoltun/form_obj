RSpec.describe 'initialize attributes: Nested Struct' do
  shared_examples 'nested Struct' do
    let(:struct) { struct_class.new(hash) }

    let(:hash) {{
        name: 'Ferrari',
        year: 1950,
        car: {
            code: '340 F1',
            driver: 'Ascari',
            engine: {
                power: 335,
                volume: 4.1
            }
        }
    }}

    it 'has assigned values' do
      expect(struct.name).to eq 'Ferrari'
      expect(struct.year).to eq 1950
      expect(struct.car.code).to eq '340 F1'
      expect(struct.car.driver).to eq 'Ascari'
      expect(struct.car.engine.power).to eq 335
      expect(struct.car.engine.volume).to eq 4.1
    end

    it "doesn't have another attributes" do
      expect {
        struct.another_attribute
      }.to raise_error NoMethodError

      expect {
        struct.car.another_attribute
      }.to raise_error NoMethodError

      expect {
        struct.car.engine.another_attribute
      }.to raise_error NoMethodError
    end

    context 'initialize non-existent attribute' do
      let(:hash) {{ car: { engine: { a: 1 }}}}

      it 'raises' do
        expect{
          struct
        }.to raise_error FormObj::UnknownAttributeError, 'a'
      end

      context 'with raise_if_not_found parameter' do
        let(:struct) { struct_class.new(hash, opts) }

        context 'equal to true' do
          let(:opts) {{ raise_if_not_found: true }}

          it 'raises' do
            expect{
              struct
            }.to raise_error FormObj::UnknownAttributeError, 'a'
          end
        end

        context 'equal to false' do
          let(:opts) {{ raise_if_not_found: false }}

          it 'does not raise' do
            expect{
              struct
            }.not_to raise_error
          end

          it 'does not create new attribute' do
            expect{
              struct.car.engine.a
            }.to raise_error NoMethodError
          end
        end
      end
    end
  end

  context 'Implicit declaration of struct objects' do
    module InitializeAttributes
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
        end
      end
    end

    let(:struct_class) { InitializeAttributes::NestedStruct }

    it_behaves_like 'nested Struct'
  end

  context 'Explicit declaration of struct objects' do

    module InitializeAttributes
      class NestedStruct < FormObj::Struct
        class EngineStruct < FormObj::Struct
          attribute :power
          attribute :volume
        end
        class CarStruct < FormObj::Struct
          attribute :code
          attribute :driver
          attribute :engine, class: EngineStruct
        end
        class TeamStruct < FormObj::Struct
          attribute :name
          attribute :year
          attribute :car, class: CarStruct
        end
      end
    end

    let(:struct_class) { InitializeAttributes::NestedStruct::TeamStruct }

    it_behaves_like 'nested Struct'
  end
end