RSpec.describe 'to_hash: Array of Form Objects' do
  subject { struct.to_hash }

  shared_examples 'hashable struct' do
    it 'correctly presents all attributes in the hash' do
      is_expected.to eq Hash[
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
                                           power: 300,
                                           volume: 3.3
                                       }
                                   }]

                        ]
    end
  end

  context 'Implicit declaration of struct object classes' do
    module ToHash
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
        end
      end
    end

    let(:struct) { ToHash::ArrayStruct.new }
    before do
      struct.name = 'Ferrari'
      struct.year = 1950

      car = struct.cars.create
      car.code = '340 F1'
      car.driver = 'Ascari'
      car.engine.power = 335
      car.engine.volume = 4.1

      car = struct.cars.create
      car.code = '275 F1'
      car.driver = 'Villoresi'
      car.engine.power = 300
      car.engine.volume = 3.3
    end

    it_behaves_like 'hashable struct'
  end

  context 'Explicit declaration of struct object classes' do
    module ToHash
      class ArrayStruct < FormObj::Struct
        class EngineForm < FormObj::Struct
          attribute :power
          attribute :volume
        end
        class CarForm < FormObj::Struct
          attribute :code
          attribute :engine, class: EngineForm
          attribute :driver
        end
        class TeamForm < FormObj::Struct
          attribute :name
          attribute :cars, array: true, class: CarForm
          attribute :year
        end
      end
    end

    context 'dot notation' do
      let(:struct) { ToHash::ArrayStruct::TeamForm.new }
      before do
        struct.name = 'Ferrari'
        struct.year = 1950

        car = struct.cars.create
        car.code = '340 F1'
        car.driver = 'Ascari'
        car.engine.power = 335
        car.engine.volume = 4.1

        car = struct.cars.create
        car.code = '275 F1'
        car.driver = 'Villoresi'
        car.engine.power = 300
        car.engine.volume = 3.3
      end

      it_behaves_like 'hashable struct'
    end

    context 'explicit class creation notation' do
      let(:struct) { ToHash::ArrayStruct::TeamForm.new }
      before do
        engine1 = ToHash::ArrayStruct::EngineForm.new
        engine1.power = 335
        engine1.volume = 4.1

        car1 = ToHash::ArrayStruct::CarForm.new
        car1.code = '340 F1'
        car1.driver = 'Ascari'
        car1.engine = engine1

        engine2 = ToHash::ArrayStruct::EngineForm.new
        engine2.power = 300
        engine2.volume = 3.3

        car2 = ToHash::ArrayStruct::CarForm.new
        car2.code = '275 F1'
        car2.driver = 'Villoresi'
        car2.engine = engine2

        struct.name = 'Ferrari'
        struct.year = 1950
        struct.cars << car1
        struct.cars << car2
      end

      it_behaves_like 'hashable struct'
    end
  end
end