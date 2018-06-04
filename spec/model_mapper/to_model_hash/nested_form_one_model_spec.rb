RSpec.describe 'to_model_hash: Nested Form Objects - One Model' do
  subject { form.to_model_hash }

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
      form.drivers_championship.driver = 'Ascari'
      form.drivers_championship.year = 1952
    end
  end

  shared_examples 'hashable form' do
    it 'correctly presents all attributes in the hash' do
      is_expected.to eq Hash[
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
                            suspension: {
                                front: 'independant',
                                rear: 'de Dion'
                            },
                            brakes: :drum
                        ]
    end
  end

  describe 'Implicit declaration of form object classes' do
    module ToModelHash
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
        attribute :chassis, model_nesting: false do
          attribute :suspension do
            attribute :front
            attribute :rear
          end
          attribute :brakes
        end
        attribute :drivers_championship, model_attribute: false do
          attribute :driver
          attribute :year
        end
      end
    end

    let(:form) { ToModelHash::NestedForm.new }

    include_context 'initialize form'
    it_behaves_like 'hashable form'
  end

  context 'Explicit declaration of form object classes' do
    module ToModelHash
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
        class DriversChampionshipForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :driver
          attribute :year
        end
        class TeamForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :name, model_attribute: :team_name
          attribute :car, class: CarForm, model_hash: true
          attribute :year
          attribute :chassis, class: ChassisForm, model_nesting: false
          attribute :drivers_championship, class: DriversChampionshipForm, model_attribute: false
        end
      end
    end

    let(:form) { ToModelHash::NestedForm::TeamForm.new }

    include_context 'initialize form'
    it_behaves_like 'hashable form'
  end
end