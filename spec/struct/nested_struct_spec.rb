RSpec.describe 'Nested Struct' do
  shared_examples 'nested Struct' do
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
  end

  context 'Implicit declaration of struct objects' do
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

    let(:struct) { NestedStruct.new }
    before do
      struct.name = 'Ferrari'
      struct.year = 1950
      struct.car.code = '340 F1'
      struct.car.driver = 'Ascari'
      struct.car.engine.power = 335
      struct.car.engine.volume = 4.1
    end

    it_behaves_like 'nested Struct'
  end

  context 'Explicit declaration of struct objects' do

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
    let(:struct) { NestedStruct::TeamStruct.new }

    context 'implicit creation of nested struct instances (via dot notation)' do
      before do
        struct.name = 'Ferrari'
        struct.year = 1950
        struct.car.code = '340 F1'
        struct.car.driver = 'Ascari'
        struct.car.engine.power = 335
        struct.car.engine.volume = 4.1
      end

      it_behaves_like 'nested Struct'
    end

    context 'explicit creation of nested struct instances' do
      let(:car_struct) { NestedStruct::CarStruct.new }
      let(:engine_struct) { NestedStruct::EngineStruct.new }
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

      it_behaves_like 'nested Struct'
    end
  end
end