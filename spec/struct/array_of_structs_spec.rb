RSpec.describe 'Array of Struct' do
  shared_examples 'nested Struct' do
    it 'has assigned values' do
      expect(struct.name).to eq 'Ferrari'
      expect(struct.year).to eq 1950
      
      expect(struct.cars[0].code).to eq '340 F1'
      expect(struct.cars[0].driver).to eq 'Ascari'
      expect(struct.cars[0].engine.power).to eq 335
      expect(struct.cars[0].engine.volume).to eq 4.1

      expect(struct.cars[1].code).to eq '275 F1'
      expect(struct.cars[1].driver).to eq 'Villoresi'
      expect(struct.cars[1].engine.power).to eq 300
      expect(struct.cars[1].engine.volume).to eq 3.3
    end

    it "doesn't have another attributes" do
      expect {
        struct.another_attribute
      }.to raise_error NoMethodError
    end
  end

  context 'Implicit declaration of struct objects' do
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

    let(:struct) { ArrayStruct.new }
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

    it { expect(struct.cars.size).to eq 2 }
    it_behaves_like 'nested Struct'
  end

  context 'Explicit declaration of struct objects' do
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
        attribute :cars, array: true, class: CarStruct
      end
    end

    context 'implicit creation of array of struct objects (via dot notation)' do
      let(:struct) { ArrayStruct::TeamStruct.new }
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

      it { expect(struct.cars.size).to eq 2 }
      it_behaves_like 'nested Struct'
    end

    context 'explicit creation of array of struct objects' do
      let(:struct) { ArrayStruct::TeamStruct.new }
      before do
        engine1 = ArrayStruct::EngineStruct.new
        engine1.power = 335
        engine1.volume = 4.1

        car1 = ArrayStruct::CarStruct.new
        car1.code = '340 F1'
        car1.driver = 'Ascari'
        car1.engine = engine1

        engine2 = ArrayStruct::EngineStruct.new
        engine2.power = 300
        engine2.volume = 3.3

        car2 = ArrayStruct::CarStruct.new
        car2.code = '275 F1'
        car2.driver = 'Villoresi'
        car2.engine = engine2

        struct.name = 'Ferrari'
        struct.year = 1950
        struct.cars << car1
        struct.cars << car2
      end

      it { expect(struct.cars.size).to eq 2 }
      it_behaves_like 'nested Struct'
    end
  end
end