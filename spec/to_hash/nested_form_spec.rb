RSpec.describe FormObj, concept: true do
  subject { form.to_hash }

  shared_examples 'hashable form' do
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

  describe 'nested form - to_hash' do
    module NestedForm
      module ToHash
        class Form < FormObj
          attribute :name
          attribute :car do
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

    let(:form) { NestedForm::ToHash::Form.new }
    before do
      form.name = 'Ferrari'
      form.year = 1950
      form.car.model = '340 F1'
      form.car.driver = 'Ascari'
      form.car.engine.power = 335
      form.car.engine.volume = 4.1
    end

    it_behaves_like 'hashable form'
  end

  describe 'explicit declaration of each nested form - to_hash' do

    module NestedForm
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
          attribute :car, class: CarForm
          attribute :year
        end
      end
    end

    context 'dot notation' do
      let(:form) { NestedForm::ToHash::TeamForm.new }
      before do
        form.name = 'Ferrari'
        form.year = 1950
        form.car.model = '340 F1'
        form.car.driver = 'Ascari'
        form.car.engine.power = 335
        form.car.engine.volume = 4.1
      end

      it_behaves_like 'hashable form'
    end

    context 'explicit class creation notation' do
      let(:form) { NestedForm::ToHash::TeamForm.new }
      let(:car_form) { NestedForm::ToHash::CarForm.new }
      let(:engine_form) { NestedForm::ToHash::EngineForm.new }
      before do
        engine_form.power = 335
        engine_form.volume = 4.1

        car_form.model = '340 F1'
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