RSpec.describe 'Array of Form Objects' do
  shared_examples 'array of Form Objects' do
    it 'has assigned values' do
      expect(tree_struct.name).to eq 'Ferrari'
      expect(tree_struct.year).to eq 1950
      
      expect(tree_struct.cars[0].code).to eq '340 F1'
      expect(tree_struct.cars[0].driver).to eq 'Ascari'
      expect(tree_struct.cars[0].engine.power).to eq 335
      expect(tree_struct.cars[0].engine.volume).to eq 4.1

      expect(tree_struct.cars[1].code).to eq '275 F1'
      expect(tree_struct.cars[1].driver).to eq 'Villoresi'
      expect(tree_struct.cars[1].engine.power).to eq 300
      expect(tree_struct.cars[1].engine.volume).to eq 3.3
    end

    it "doesn't have another attributes" do
      expect {
        tree_struct.another_attribute
      }.to raise_error NoMethodError
    end
  end

  context 'Implicit declaration of tree_struct objects' do
    class ArrayForm < FormObj::Form
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

    let(:tree_struct) { ArrayForm.new }
    before do
      tree_struct.name = 'Ferrari'
      tree_struct.year = 1950

      car = tree_struct.cars.create
      car.code = '340 F1'
      car.driver = 'Ascari'
      car.engine.power = 335
      car.engine.volume = 4.1

      car = tree_struct.cars.create
      car.code = '275 F1'
      car.driver = 'Villoresi'
      car.engine.power = 300
      car.engine.volume = 3.3
    end

    it { expect(tree_struct.cars.size).to eq 2 }
    it_behaves_like 'array of Form Objects'
  end

  context 'Explicit declaration of tree_struct objects' do
    class ArrayForm < FormObj::Form
      class EngineForm < FormObj::Form
        attribute :power
        attribute :volume
      end
      class CarForm < FormObj::Form
        attribute :code
        attribute :driver
        attribute :engine, class: EngineForm
      end
      class TeamForm < FormObj::Form
        attribute :name
        attribute :year
        attribute :cars, array: true, class: CarForm
      end
    end

    context 'implicit creation of array of tree_struct objects (via dot notation)' do
      let(:tree_struct) { ArrayForm::TeamForm.new }
      before do
        tree_struct.name = 'Ferrari'
        tree_struct.year = 1950

        car = tree_struct.cars.create
        car.code = '340 F1'
        car.driver = 'Ascari'
        car.engine.power = 335
        car.engine.volume = 4.1

        car = tree_struct.cars.create
        car.code = '275 F1'
        car.driver = 'Villoresi'
        car.engine.power = 300
        car.engine.volume = 3.3
      end

      it { expect(tree_struct.cars.size).to eq 2 }
      it_behaves_like 'array of Form Objects'
    end

    context 'explicit creation of array of tree_struct objects' do
      let(:tree_struct) { ArrayForm::TeamForm.new }
      before do
        engine1 = ArrayForm::EngineForm.new
        engine1.power = 335
        engine1.volume = 4.1

        car1 = ArrayForm::CarForm.new
        car1.code = '340 F1'
        car1.driver = 'Ascari'
        car1.engine = engine1

        engine2 = ArrayForm::EngineForm.new
        engine2.power = 300
        engine2.volume = 3.3

        car2 = ArrayForm::CarForm.new
        car2.code = '275 F1'
        car2.driver = 'Villoresi'
        car2.engine = engine2

        tree_struct.name = 'Ferrari'
        tree_struct.year = 1950
        tree_struct.cars << car1
        tree_struct.cars << car2
      end

      it { expect(tree_struct.cars.size).to eq 2 }
      it_behaves_like 'array of Form Objects'
    end
  end
end