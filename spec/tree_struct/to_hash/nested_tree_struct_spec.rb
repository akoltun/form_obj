RSpec.describe 'to_hash: Nested TreeStruct' do
  subject { tree_struct.to_hash }

  shared_examples 'hashable tree_struct' do
    it 'correctly presents all attributes in the hash' do
      is_expected.to eq Hash[
                            name: 'Ferrari',
                            year: 1950,
                            car: {
                                model: '340 F1',
                                driver: 'Ascari',
                                engine: {
                                    power: 335,
                                    volume: 4.1
                                }
                            }

                        ]
    end
  end

  describe 'Implicit declaration of tree_struct object classes' do
    module ToHash
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
    end

    let(:tree_struct) { ToHash::NestedTreeStruct.new }
    before do
      tree_struct.name = 'Ferrari'
      tree_struct.year = 1950
      tree_struct.car.model = '340 F1'
      tree_struct.car.driver = 'Ascari'
      tree_struct.car.engine.power = 335
      tree_struct.car.engine.volume = 4.1
    end

    it_behaves_like 'hashable tree_struct'
  end

  context 'Explicit declaration of tree_struct object classes' do
    module ToHash
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
    end

    context 'dot notation' do
      let(:tree_struct) { ToHash::NestedTreeStruct::TeamTreeStruct.new }
      before do
        tree_struct.name = 'Ferrari'
        tree_struct.year = 1950
        tree_struct.car.model = '340 F1'
        tree_struct.car.driver = 'Ascari'
        tree_struct.car.engine.power = 335
        tree_struct.car.engine.volume = 4.1
      end

      it_behaves_like 'hashable tree_struct'
    end

    context 'explicit class creation notation' do
      let(:tree_struct) { ToHash::NestedTreeStruct::TeamTreeStruct.new }
      let(:car_tree_struct) { ToHash::NestedTreeStruct::CarTreeStruct.new }
      let(:engine_tree_struct) { ToHash::NestedTreeStruct::EngineTreeStruct.new }
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

      it_behaves_like 'hashable tree_struct'
    end
  end
end