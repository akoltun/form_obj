RSpec.describe 'Array of Form Objects' do
  shared_examples 'array of Form Objects' do
    it 'has assigned values' do
      expect(form.name).to eq 'Ferrari'
      expect(form.year).to eq 1950
      
      expect(form.cars[0].code).to eq '340 F1'
      expect(form.cars[0].driver).to eq 'Ascari'
      expect(form.cars[0].engine.power).to eq 335
      expect(form.cars[0].engine.volume).to eq 4.1

      expect(form.cars[1].code).to eq '275 F1'
      expect(form.cars[1].driver).to eq 'Villoresi'
      expect(form.cars[1].engine.power).to eq 300
      expect(form.cars[1].engine.volume).to eq 3.3
    end

    it "doesn't have another attributes" do
      expect {
        form.another_attribute
      }.to raise_error NoMethodError
    end
  end

  context 'Implicit declaration of form objects' do
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

    let(:form) { ArrayForm.new }
    before do
      form.name = 'Ferrari'
      form.year = 1950

      car = form.cars.create
      car.code = '340 F1'
      car.driver = 'Ascari'
      car.engine.power = 335
      car.engine.volume = 4.1

      car = form.cars.create
      car.code = '275 F1'
      car.driver = 'Villoresi'
      car.engine.power = 300
      car.engine.volume = 3.3
    end

    it { expect(form.cars.size).to eq 2 }
    it_behaves_like 'array of Form Objects'
  end

  context 'Explicit declaration of form objects' do
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

    context 'implicit creation of array of form objects (via dot notation)' do
      let(:form) { ArrayForm::TeamForm.new }
      before do
        form.name = 'Ferrari'
        form.year = 1950

        car = form.cars.create
        car.code = '340 F1'
        car.driver = 'Ascari'
        car.engine.power = 335
        car.engine.volume = 4.1

        car = form.cars.create
        car.code = '275 F1'
        car.driver = 'Villoresi'
        car.engine.power = 300
        car.engine.volume = 3.3
      end

      it { expect(form.cars.size).to eq 2 }
      it_behaves_like 'array of Form Objects'
    end

    context 'explicit creation of array of form objects' do
      let(:form) { ArrayForm::TeamForm.new }
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

        form.name = 'Ferrari'
        form.year = 1950
        form.cars << car1
        form.cars << car2
      end

      it { expect(form.cars.size).to eq 2 }
      it_behaves_like 'array of Form Objects'
    end
  end
end