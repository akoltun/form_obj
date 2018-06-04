RSpec.describe 'update_attributes: Nested Struct' do
  shared_examples 'updated struct' do
    let(:update_attributes) {
      struct.update_attributes(
          name: 'McLaren',
          year: 1966,
          car: {
              code: 'M2B',
              driver: 'Bruce McLaren',
              engine: {
                  power: 300,
                  volume: 3.0
              }
          }
      )
    }

    it 'has all attributes correctly updated' do
      update_attributes

      expect(struct.name).to              eq 'McLaren'
      expect(struct.year).to              eq 1966
      expect(struct.car.code).to         eq 'M2B'
      expect(struct.car.driver).to        eq 'Bruce McLaren'
      expect(struct.car.engine.power).to  eq 300
      expect(struct.car.engine.volume).to eq 3.0
    end

    it 'returns self' do
      expect(update_attributes).to eql struct
    end
  end

  describe 'Implicit declaration of struct objects' do
    module UpdateAttributes
      class NestedStruct < FormObj::Struct
        attribute :name
        attribute :car do
          attribute :code
          attribute :engine do
            attribute :power
            attribute :volume
          end
          attribute :driver
        end
        attribute :year
      end
    end

    let(:struct) { UpdateAttributes::NestedStruct.new }

    context 'nested structs present already' do
      before do
        struct.name = 'Ferrari'
        struct.year = 1950
        struct.car.code = '340 F1'
        struct.car.driver = 'Ascari'
        struct.car.engine.power = 335
        struct.car.engine.volume = 4.1
      end

      it_behaves_like 'updated struct'
    end

    context 'nested structs not present yet' do
      before do
        struct.name = 'Ferrari'
        struct.year = 1950
      end

      it_behaves_like 'updated struct'
    end
  end

  context 'Explicit declaration of struct objects' do
    module UpdateAttributes
      class NestedStruct < FormObj::Struct
        class EngineStruct < FormObj::Struct
          attribute :power
          attribute :volume
        end
        class CarStruct < FormObj::Struct
          attribute :code
          attribute :engine, class: EngineStruct
          attribute :driver
        end
        class TeamStruct < FormObj::Struct
          attribute :name
          attribute :car, class: CarStruct
          attribute :year
        end
      end
    end
    let(:struct) { UpdateAttributes::NestedStruct::TeamStruct.new }

    context 'nested structs present already' do
      context 'implicit creation of nested struct object instances (via dot notation)' do
        before do
          struct.name = 'Ferrari'
          struct.year = 1950
          struct.car.code = '340 F1'
          struct.car.driver = 'Ascari'
          struct.car.engine.power = 335
          struct.car.engine.volume = 4.1
        end

        it_behaves_like 'updated struct'
      end
      context 'explicit creation of nested struct object instances' do
        let(:car_struct) { UpdateAttributes::NestedStruct::CarStruct.new }
        let(:engine_struct) { UpdateAttributes::NestedStruct::EngineStruct.new }
        before do
          engine_struct.power = 335
          engine_struct.volume = 4.1

          car_struct.code = '340 F1'
          car_struct.driver = 'Ascari'
          car_struct.engine = engine_struct

          struct.name = 'Ferrari'
          struct.year = 1950
          struct.car = car_struct
        end

        it_behaves_like 'updated struct'
      end

    end

    context 'nested structs not present yet' do
      before do
        struct.name = 'Ferrari'
        struct.year = 1950
      end

      it_behaves_like 'updated struct'
    end
  end
end