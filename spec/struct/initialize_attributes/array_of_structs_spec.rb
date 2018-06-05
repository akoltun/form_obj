RSpec.describe 'initialize attributes: Array of Struct' do
  shared_examples 'array of structs' do
    let(:struct) { struct_class.new(hash) }

    let(:hash) {{
        name: 'Ferrari',
        year: 1950,
        cars: [{
                   code: '340 F1',
                   driver: 'Ascari',
                   engine: {
                       power: 335,
                       volume: 4.1
                   }
               }, {
                   code: '275 F1',
                   driver: 'Villoresi',
                   engine: {
                       power: 330,
                       volume: 3.3
                   }
               }]
    }}

    it 'has assigned values' do
      expect(struct.name).to eq 'Ferrari'
      expect(struct.year).to eq 1950

      expect(struct.cars.size).to eq 2

      expect(struct.cars[0].code).to eq '340 F1'
      expect(struct.cars[0].driver).to eq 'Ascari'
      expect(struct.cars[0].engine.power).to eq 335
      expect(struct.cars[0].engine.volume).to eq 4.1

      expect(struct.cars[1].code).to eq '275 F1'
      expect(struct.cars[1].driver).to eq 'Villoresi'
      expect(struct.cars[1].engine.power).to eq 330
      expect(struct.cars[1].engine.volume).to eq 3.3
    end

    it "doesn't have another attributes" do
      expect {
        struct.another_attribute
      }.to raise_error NoMethodError
    end

    context 'initialize non-existent attribute' do
      let(:hash) {{ cars: [{ code: '340 F1', engine: { a: 1 }}]}}

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
              struct.cars[0].engine.a
            }.to raise_error NoMethodError
          end
        end
      end
    end
  end

  context 'Implicit declaration of struct objects' do
    context 'primary_key specified on attribute level' do
      module InitializeAttributes
        module PrimaryKeyAttributeLevel
          class ArrayStruct < FormObj::Struct
            attribute :name
            attribute :year
            attribute :cars, array: true do
              attribute :code, primary_key: true
              attribute :driver
              attribute :engine do
                attribute :power
                attribute :volume
              end
            end
          end
        end
      end

      let(:struct_class) { InitializeAttributes::PrimaryKeyAttributeLevel::ArrayStruct }

      it_behaves_like 'array of structs'
    end

    context 'primary_key specified on struct level' do
      module InitializeAttributes
        module PrimaryKeyStructLevel
          class ArrayStruct < FormObj::Struct
            attribute :name
            attribute :year
            attribute :cars, array: true, primary_key: :code do
              attribute :code
              attribute :driver
              attribute :engine do
                attribute :power
                attribute :volume
              end
            end
          end
        end
      end

      let(:struct_class) { InitializeAttributes::PrimaryKeyStructLevel::ArrayStruct }

      it_behaves_like 'array of structs'
    end
  end

  context 'Explicit declaration of struct objects' do
    context 'primary_key specified on attribute level' do
      module InitializeAttributes
        module PrimaryKeyAttributeLevel
          class ArrayStruct < FormObj::Struct
            class EngineStruct < FormObj::Struct
              attribute :power
              attribute :volume
            end
            class CarStruct < FormObj::Struct
              attribute :code, primary_key: true
              attribute :driver
              attribute :engine, class: EngineStruct
            end
            class TeamStruct < FormObj::Struct
              attribute :name
              attribute :year
              attribute :cars, array: true, class: CarStruct
            end
          end
        end
      end

      let(:struct_class) { InitializeAttributes::PrimaryKeyAttributeLevel::ArrayStruct::TeamStruct }

      it_behaves_like 'array of structs'
    end

    context 'primary_key specified on struct level' do
      module InitializeAttributes
        module PrimaryKeyStructLevel
          class ArrayStruct < FormObj::Struct
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
              attribute :cars, array: true, primary_key: :code, class: CarStruct
            end
          end
        end
      end

      let(:struct_class) { InitializeAttributes::PrimaryKeyStructLevel::ArrayStruct::TeamStruct }

      it_behaves_like 'array of structs'
    end
  end
end