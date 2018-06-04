RSpec.describe 'to_models_hash: Nested Form Objects - Few Models' do
  shared_context 'initialize form' do
    before do
      form.name = 'Ferrari'
      form.year = 1950
      form.car.code = '340 F1'
      form.car.driver = 'Ascari'
      form.car.engine.power = 335
      form.car.engine.volume = 4.1
      form.chassis.suspension.front = 'independant'
      form.chassis.suspension.rear = 'de Dion'
      form.chassis.brakes = :drum
    end
  end

  shared_examples 'hashable form' do
    it 'correctly presents all attributes in the hash' do
      expect(form.to_models_hash).to eq Hash[
                                            default: {
                                                team_name: 'Ferrari',
                                                year: 1950,
                                                car: {
                                                    car_code: '340 F1',
                                                    driver: 'Ascari',
                                                    engine: {
                                                        power: 335,
                                                        volume: 4.1
                                                    }
                                                },
                                            },
                                            chassis: {
                                                suspension: {
                                                    front: 'independant',
                                                    rear: 'de Dion'
                                                },
                                                brakes: :drum

                                            }
                                        ]


      expect(form.to_model_hash).to eq Hash[
                                           team_name: 'Ferrari',
                                           year: 1950,
                                           car: {
                                               car_code: '340 F1',
                                               driver: 'Ascari',
                                               engine: {
                                                   power: 335,
                                                   volume: 4.1
                                               }
                                           },
                                       ]

      expect(form.to_model_hash(:chassis)).to eq Hash[
                                                     suspension: {
                                                         front: 'independant',
                                                         rear: 'de Dion'
                                                     },
                                                     brakes: :drum
                                                 ]
    end
  end

  describe 'Implicit declaration of form object classes' do
    module ToModelsHash
      class NestedForm < FormObj::Form
        include FormObj::ModelMapper

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :car, model_hash: true do
          attribute :code, model_attribute: :car_code
          attribute :engine do
            attribute :power
            attribute :volume
          end
          attribute :driver
        end
        attribute :chassis, model_attribute: false, model: :chassis do
          attribute :suspension do
            attribute :front
            attribute :rear
          end
          attribute :brakes
        end
      end
    end

    let(:form) { ToModelsHash::NestedForm.new }

    include_context 'initialize form'
    it_behaves_like 'hashable form'
  end

  context 'Explicit declaration of form object classes' do
    module ToModelsHash
      class NestedForm < FormObj::Form
        class EngineForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :power
          attribute :volume
        end
        class CarForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :code, model_attribute: :car_code
          attribute :engine, class: EngineForm
          attribute :driver
        end
        class ChassisForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :suspension do
            attribute :front
            attribute :rear
          end
          attribute :brakes
        end
        class TeamForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :name, model_attribute: :team_name
          attribute :car, class: CarForm, model_hash: true
          attribute :year
          attribute :chassis, class: ChassisForm, model_attribute: false, model: :chassis
        end
      end
    end

    let(:form) { ToModelsHash::NestedForm::TeamForm.new }

    include_context 'initialize form'
    it_behaves_like 'hashable form'
  end
end
