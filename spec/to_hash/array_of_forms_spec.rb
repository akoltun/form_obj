RSpec.describe FormObj, concept: true do
  subject { form.to_hash }

  shared_examples 'hashable form' do
    it 'correctly presents all attributes in the hash' do
      is_expected.to eq Hash[
                            name: 'Ferrari',
                            year: 1950,
                            cars: [{
                                       model: '340 F1',
                                       driver: 'Ascari',
                                       engine: {
                                           power: 335,
                                           volume: 4.1
                                       }
                                   }, {
                                       model: '275 F1',
                                       driver: 'Villoresi',
                                       engine: {
                                           power: 300,
                                           volume: 3.3
                                       }
                                   }]

                        ]
    end
  end

  describe 'array of nested forms - to_hash' do
    module ArrayOfForms
      module ToHash
        class Form < FormObj
          attribute :name
          attribute :cars, array: true do
            attribute :model
            attribute :engine do
              attribute :power
              attribute :volume
            end
            attribute :driver
          end
          attribute :year
        end
      end
    end

    let(:form) { ArrayOfForms::ToHash::Form.new }
    before do
      form.name = 'Ferrari'
      form.year = 1950

      car = form.cars.create
      car.model = '340 F1'
      car.driver = 'Ascari'
      car.engine.power = 335
      car.engine.volume = 4.1

      car = form.cars.create
      car.model = '275 F1'
      car.driver = 'Villoresi'
      car.engine.power = 300
      car.engine.volume = 3.3
    end

    it_behaves_like 'hashable form'
  end

  describe 'explicit declaration of nested forms in array - to_hash' do

    module ArrayOfForms
      module ToHash
        class EngineForm < FormObj
          attribute :power
          attribute :volume
        end
        class CarForm < FormObj
          attribute :model
          attribute :engine, class: EngineForm
          attribute :driver
        end
        class TeamForm < FormObj
          attribute :name
          attribute :cars, array: true, class: CarForm
          attribute :year
        end
      end
    end

    context 'dot notation' do
      let(:form) { ArrayOfForms::ToHash::TeamForm.new }
      before do
        form.name = 'Ferrari'
        form.year = 1950

        car = form.cars.create
        car.model = '340 F1'
        car.driver = 'Ascari'
        car.engine.power = 335
        car.engine.volume = 4.1

        car = form.cars.create
        car.model = '275 F1'
        car.driver = 'Villoresi'
        car.engine.power = 300
        car.engine.volume = 3.3
      end

      it_behaves_like 'hashable form'
    end

    context 'explicit class creation notation' do
      let(:form) { ArrayOfForms::ToHash::TeamForm.new }
      before do
        engine1 = ArrayOfForms::ToHash::EngineForm.new
        engine1.power = 335
        engine1.volume = 4.1

        car1 = ArrayOfForms::ToHash::CarForm.new
        car1.model = '340 F1'
        car1.driver = 'Ascari'
        car1.engine = engine1

        engine2 = ArrayOfForms::ToHash::EngineForm.new
        engine2.power = 300
        engine2.volume = 3.3

        car2 = ArrayOfForms::ToHash::CarForm.new
        car2.model = '275 F1'
        car2.driver = 'Villoresi'
        car2.engine = engine2

        form.name = 'Ferrari'
        form.year = 1950
        form.cars << car1
        form.cars << car2
      end

      it_behaves_like 'hashable form'
    end
  end
end