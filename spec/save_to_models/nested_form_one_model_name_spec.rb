RSpec.describe FormObj, concept: true do
  describe 'SaveToModel: nested form - one model - name' do

    Suspension = Struct.new(:front, :rear)
    module SaveToModel
      module NestedForm
        module OneModelName
          Engine = Struct.new(:power, :volume)
          Suspension = Struct.new(:front, :rear)
        end
      end
    end

    let(:engine) { SaveToModel::NestedForm::OneModelName::Engine.new }
    let(:suspension) { SaveToModel::NestedForm::OneModelName::Suspension.new }
    let(:model) { Struct.new(:team_name, :year, :car, :suspension, :brakes).new }

    context 'nested models are created when they do not exist yet' do
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

        form.save_to_model(model)
      end

      describe 'nested form' do
        module SaveToModel
          module NestedForm
            module OneModelName
              class Form < FormObj
                attribute :name, model_attribute: :team_name
                attribute :year
                attribute :car, hash: true do
                  attribute :model
                  attribute :engine, model_class: 'SaveToModel::NestedForm::OneModelName::Engine' do
                    attribute :power
                    attribute :volume
                  end
                  attribute :driver
                end
                attribute :chassis, model_attribute: false do
                  attribute :suspension, model_class: 'SaveToModel::NestedForm::OneModelName::Suspension' do
                    attribute :front
                    attribute :rear
                  end
                  attribute :brakes
                end
              end
            end
          end
        end

        let(:form) { SaveToModel::NestedForm::OneModelName::Form.new }

        it 'has all attributes correctly saved' do
          expect(model.team_name).to            eq form.name
          expect(model.year).to                 eq form.year
          expect(model.car[:model]).to          eq form.car.model
          expect(model.car[:driver]).to         eq form.car.driver
          expect(model.car[:engine].power).to   eq form.car.engine.power
          expect(model.car[:engine].volume).to  eq form.car.engine.volume
          expect(model.suspension.front).to     eq form.chassis.suspension.front
          expect(model.suspension.rear).to      eq form.chassis.suspension.rear
          expect(model.brakes).to               eq form.chassis.brakes
        end

        it 'returns self' do
          expect(form.save_to_model(model)).to eql form
        end
      end

      describe 'explicit declaration of nested form classes' do
        module SaveToModel
          module NestedForm
            module OneModelName
              class EngineForm < FormObj
                attribute :power
                attribute :volume
              end
              class CarForm < FormObj
                attribute :model
                attribute :engine, class: EngineForm, model_class: 'SaveToModel::NestedForm::OneModelName::Engine'
                attribute :driver
              end
              class ChassisForm < FormObj
                attribute :suspension, model_class: 'SaveToModel::NestedForm::OneModelName::Suspension' do
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

        let(:form) { SaveToModel::NestedForm::OneModelName::TeamForm.new }

        it 'has all attributes correctly saved' do
          expect(model.team_name).to            eq form.name
          expect(model.year).to                 eq form.year
          expect(model.car[:model]).to          eq form.car.model
          expect(model.car[:driver]).to         eq form.car.driver
          expect(model.car[:engine].power).to   eq form.car.engine.power
          expect(model.car[:engine].volume).to  eq form.car.engine.volume
          expect(model.suspension.front).to     eq form.chassis.suspension.front
          expect(model.suspension.rear).to      eq form.chassis.suspension.rear
          expect(model.brakes).to               eq form.chassis.brakes
        end

        it 'returns self' do
          expect(form.save_to_model(model)).to eql form
        end
      end
    end

    context 'nested models are updated when they exists already' do
      let(:car) {{ engine: engine }}

      before do
        model.car = car
        model.suspension = suspension

        form.name = 'Ferrari'
        form.year = 1950
        form.car.model = '340 F1'
        form.car.driver = 'Ascari'
        form.car.engine.power = 335
        form.car.engine.volume = 4.1
        form.chassis.suspension.front = 'independant'
        form.chassis.suspension.rear = 'de Dion'
        form.chassis.brakes = :drum

        form.save_to_model(model)
      end

      describe 'nested form' do
        module SaveToModel
          module NestedForm
            module OneModelName
              class Form < FormObj
                attribute :name, model_attribute: :team_name
                attribute :year
                attribute :car, hash: true do
                  attribute :model
                  attribute :engine, model_class: 'SaveToModel::NestedForm::OneModelName::Engine' do
                    attribute :power
                    attribute :volume
                  end
                  attribute :driver
                end
                attribute :chassis, model_attribute: false do
                  attribute :suspension, model_class: 'SaveToModel::NestedForm::OneModelName::Suspension' do
                    attribute :front
                    attribute :rear
                  end
                  attribute :brakes
                end
              end
            end
          end
        end

        let(:form) { SaveToModel::NestedForm::OneModelName::Form.new }

        it 'has all attributes correctly saved' do
          expect(model.team_name).to            eq form.name
          expect(model.year).to                 eq form.year
          expect(model.car[:model]).to          eq form.car.model
          expect(model.car[:driver]).to         eq form.car.driver
          expect(model.car[:engine].power).to   eq form.car.engine.power
          expect(model.car[:engine].volume).to  eq form.car.engine.volume
          expect(model.suspension.front).to     eq form.chassis.suspension.front
          expect(model.suspension.rear).to      eq form.chassis.suspension.rear
          expect(model.brakes).to               eq form.chassis.brakes
        end

        it "doesn't create new nested models" do
          expect(model.car).to eql car
          expect(model.suspension).to eql suspension
        end

        it 'returns self' do
          expect(form.save_to_model(model)).to eql form
        end
      end

      describe 'explicit declaration of nested form classes' do
        module SaveToModel
          module NestedForm
            module OneModelName
              class EngineForm < FormObj
                attribute :power
                attribute :volume
              end
              class CarForm < FormObj
                attribute :model
                attribute :engine, class: EngineForm, model_class: 'SaveToModel::NestedForm::OneModelName::Engine'
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

        let(:form) { SaveToModel::NestedForm::OneModelName::TeamForm.new }

        it 'has all attributes correctly saved' do
          expect(model.team_name).to            eq form.name
          expect(model.year).to                 eq form.year
          expect(model.car[:model]).to          eq form.car.model
          expect(model.car[:driver]).to         eq form.car.driver
          expect(model.car[:engine].power).to   eq form.car.engine.power
          expect(model.car[:engine].volume).to  eq form.car.engine.volume
          expect(model.suspension.front).to     eq form.chassis.suspension.front
          expect(model.suspension.rear).to      eq form.chassis.suspension.rear
          expect(model.brakes).to               eq form.chassis.brakes
        end

        it "doesn't create new nested models" do
          expect(model.car).to eql car
          expect(model.suspension).to eql suspension
        end

        it 'returns self' do
          expect(form.save_to_model(model)).to eql form
        end
      end
    end
  end
end