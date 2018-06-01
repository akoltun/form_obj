RSpec.describe 'to_hash: Nested Struct' do
  subject { struct.to_hash }

  shared_examples 'hashable struct' do
    it 'correctly presents all attributes in the hash' do
      is_expected.to eq Hash[
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

                        ]
    end
  end

  describe 'Implicit declaration of struct object classes' do
    module ToHash
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

    let(:struct) { ToHash::NestedStruct.new }
    before do
      struct.name = 'Ferrari'
      struct.year = 1950
      struct.car.code = '340 F1'
      struct.car.driver = 'Ascari'
      struct.car.engine.power = 335
      struct.car.engine.volume = 4.1
    end

    it_behaves_like 'hashable struct'
  end

  context 'Explicit declaration of struct object classes' do
    module ToHash
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

    context 'dot notation' do
      let(:struct) { ToHash::NestedStruct::TeamStruct.new }
      before do
        struct.name = 'Ferrari'
        struct.year = 1950
        struct.car.code = '340 F1'
        struct.car.driver = 'Ascari'
        struct.car.engine.power = 335
        struct.car.engine.volume = 4.1
      end

      it_behaves_like 'hashable struct'
    end

    context 'explicit class creation notation' do
      let(:struct) { ToHash::NestedStruct::TeamStruct.new }
      let(:car_struct) { ToHash::NestedStruct::CarStruct.new }
      let(:engine_struct) { ToHash::NestedStruct::EngineStruct.new }
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

      it_behaves_like 'hashable struct'
    end
  end
end