RSpec.describe FormObj, concept: true do
  describe 'to_model_hash: nested form - one model' do
    subject { form.to_model_hash }

    shared_context 'init form' do
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
        is_expected.to eq Hash[
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
                              suspension: {
                                  front: 'independant',
                                  rear: 'de Dion'
                              },
                              brakes: :drum
                          ]
      end
    end

    describe 'nested form' do
      module ToModelHash
        module NestedForm
          module OneModel
            class Form < FormObj
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
              attribute :chassis, model_attribute: false do
                attribute :suspension do
                  attribute :front
                  attribute :rear
                end
                attribute :brakes
              end
            end
          end
        end
      end

      let(:form) { ToModelHash::NestedForm::OneModel::Form.new }

      include_context 'init form'
      it_behaves_like 'hashable form'
    end

    describe 'explicit declaration of nested form classes' do
      module ToModelHash
        module NestedForm
          module OneModel
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
              attribute :chassis, class: ChassisForm, model_attribute: false
            end
          end
        end
      end

      let(:form) { ToModelHash::NestedForm::OneModel::TeamForm.new }

      include_context 'init form'
      it_behaves_like 'hashable form'
    end
  end
end