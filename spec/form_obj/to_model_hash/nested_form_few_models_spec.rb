RSpec.describe 'to_model_hash: Nested Form Objects - Few Models' do
  shared_context 'initialize form' do
    before do
      form.name = 'Ferrari'
      form.year = 1950
      form.car.model = '340 F1'
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
      expect(form.to_model_hash).to eq Hash[
                                           team_name: 'Ferrari',
                                           year: 1950,
                                           car: {
                                               car_model: '340 F1',
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
    module ToModelHash
      module FewModels
        class ImplicitNestedForm < FormObj
          attribute :name, model_attribute: :team_name
          attribute :year
          attribute :car, hash: true do
            attribute :model, model_attribute: :car_model
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
    end

    let(:form) { ToModelHash::FewModels::ImplicitNestedForm.new }

    include_context 'initialize form'
    it_behaves_like 'hashable form'
  end

  context 'Explicit declaration of form object classes' do
    module ToModelHash
      module FewModels
        module ExplicitNested
          class EngineForm < FormObj
            attribute :power
            attribute :volume
          end
          class CarForm < FormObj
            attribute :model, model_attribute: :car_model
            attribute :engine, class: EngineForm
            attribute :driver
          end
          class ChassisForm < FormObj
            attribute :suspension do
              attribute :front
              attribute :rear
            end
            attribute :brakes
          end
          class TeamForm < FormObj
            attribute :name, model_attribute: :team_name
            attribute :car, class: CarForm, hash: true
            attribute :year
            attribute :chassis, class: ChassisForm, model_attribute: false, model: :chassis
          end
        end
      end
    end

    let(:form) { ToModelHash::FewModels::ExplicitNested::TeamForm.new }

    include_context 'initialize form'
    it_behaves_like 'hashable form'
  end
end
