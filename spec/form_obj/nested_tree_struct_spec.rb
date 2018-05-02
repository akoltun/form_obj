RSpec.describe 'Nested TreeStruct' do
  shared_examples 'nested TreeStruct' do
    it 'has assigned values' do
      expect(tree_struct.name).to eq 'Ferrari'
      expect(tree_struct.year).to eq 1950
      expect(tree_struct.car.model).to eq '340 F1'
      expect(tree_struct.car.driver).to eq 'Ascari'
      expect(tree_struct.car.engine.power).to eq 335
      expect(tree_struct.car.engine.volume).to eq 4.1
    end

    it "doesn't have another attributes" do
      expect {
        tree_struct.another_attribute
      }.to raise_error NoMethodError

      expect {
        tree_struct.car.another_attribute
      }.to raise_error NoMethodError

      expect {
        tree_struct.car.engine.another_attribute
      }.to raise_error NoMethodError
    end
  end

  context 'Implicit declaration of tree_struct objects' do
    class NestedTreeStruct < TreeStruct
      attribute :name
      attribute :year
      attribute :car do
        attribute :model
        attribute :driver
        attribute :engine do
          attribute :power
          attribute :volume
        end
      end
    end

    let(:tree_struct) { NestedTreeStruct.new }
    before do
      tree_struct.name = 'Ferrari'
      tree_struct.year = 1950
      tree_struct.car.model = '340 F1'
      tree_struct.car.driver = 'Ascari'
      tree_struct.car.engine.power = 335
      tree_struct.car.engine.volume = 4.1
    end

    it_behaves_like 'nested TreeStruct'
  end

  context 'Explicit declaration of tree_struct objects' do

    class NestedTreeStruct < TreeStruct
      class EngineTreeStruct < TreeStruct
        attribute :power
        attribute :volume
      end
      class CarTreeStruct < TreeStruct
        attribute :model
        attribute :driver
        attribute :engine, class: EngineTreeStruct
      end
      class TeamTreeStruct < TreeStruct
        attribute :name
        attribute :year
        attribute :car, class: CarTreeStruct
      end
    end
    let(:tree_struct) { NestedTreeStruct::TeamTreeStruct.new }

    context 'implicit creation of nested tree_struct instances (via dot notation)' do
      before do
        tree_struct.name = 'Ferrari'
        tree_struct.year = 1950
        tree_struct.car.model = '340 F1'
        tree_struct.car.driver = 'Ascari'
        tree_struct.car.engine.power = 335
        tree_struct.car.engine.volume = 4.1
      end

      it_behaves_like 'nested TreeStruct'
    end

    context 'explicit creation of nested tree_struct instances' do
      let(:car_tree_struct) { NestedTreeStruct::CarTreeStruct.new }
      let(:engine_tree_struct) { NestedTreeStruct::EngineTreeStruct.new }
      before do
        engine_tree_struct.power = 335
        engine_tree_struct.volume = 4.1

        car_tree_struct.model = '340 F1'
        car_tree_struct.driver = 'Ascari'
        car_tree_struct.engine = engine_tree_struct

        tree_struct.name = 'Ferrari'
        tree_struct.year = 1950
        tree_struct.car = car_tree_struct
      end

      it_behaves_like 'nested TreeStruct'
    end
  end
end