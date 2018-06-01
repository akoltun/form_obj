RSpec.describe 'to_hash: Nested Form Object' do
  subject { form.to_hash }

  shared_examples 'hashable form' do
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

  describe 'Implicit declaration of form object classes' do
    module ToHash
      class NestedForm < FormObj::Form
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

    let(:form) { ToHash::NestedForm.new }
    before do
      form.name = 'Ferrari'
      form.year = 1950
      form.car.code = '340 F1'
      form.car.driver = 'Ascari'
      form.car.engine.power = 335
      form.car.engine.volume = 4.1
    end

    it_behaves_like 'hashable form'
  end

  context 'Explicit declaration of form object classes' do
    module ToHash
      class NestedForm < FormObj::Form
        class EngineForm < FormObj::Form
          attribute :power
          attribute :volume
        end
        class CarForm < FormObj::Form
          attribute :code
          attribute :engine, class: EngineForm
          attribute :driver
        end
        class TeamForm < FormObj::Form
          attribute :name
          attribute :car, class: CarForm
          attribute :year
        end
      end
    end

    context 'dot notation' do
      let(:form) { ToHash::NestedForm::TeamForm.new }
      before do
        form.name = 'Ferrari'
        form.year = 1950
        form.car.code = '340 F1'
        form.car.driver = 'Ascari'
        form.car.engine.power = 335
        form.car.engine.volume = 4.1
      end

      it_behaves_like 'hashable form'
    end

    context 'explicit class creation notation' do
      let(:form) { ToHash::NestedForm::TeamForm.new }
      let(:car_form) { ToHash::NestedForm::CarForm.new }
      let(:engine_form) { ToHash::NestedForm::EngineForm.new }
      before do
        engine_form.power = 335
        engine_form.volume = 4.1

        car_form.code = '340 F1'
        car_form.driver = 'Ascari'
        car_form.engine = engine_form

        form.name = 'Ferrari'
        form.year = 1950
        form.car = car_form
      end

      it_behaves_like 'hashable form'
    end
  end
end