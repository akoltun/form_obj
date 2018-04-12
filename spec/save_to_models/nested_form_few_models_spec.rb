RSpec.describe FormObj, concept: true do
  describe 'SaveToModel: nested form - few models' do

    module SaveToModel
      module NestedForm
        module FewModels
          Engine      = Struct.new(:power, :volume)
          Suspension  = Struct.new(:front, :rear)
        end
      end
    end

    let(:model) { Struct.new(:team_name, :year, :car).new }
    let(:chassis) { Struct.new(:suspension, :brakes).new }

    describe 'nested form' do
      module SaveToModel
        module NestedForm
          module FewModels
            class Form < FormObj
              attribute :name, model_attribute: :team_name
              attribute :year
              attribute :car, hash: true do
                attribute :model
                attribute :engine, model_class: Engine do
                  attribute :power
                  attribute :volume
                end
                attribute :driver
              end
              attribute :chassis, model_attribute: false, model: :chassis do
                attribute :suspension, model_class: Suspension do
                  attribute :front
                  attribute :rear
                end
                attribute :brakes
              end
            end
          end
        end
      end

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

          form.save_to_models(default: model, chassis: chassis)
        end

        let(:form) { SaveToModel::NestedForm::FewModels::Form.new }

        it 'has all attributes correctly saved' do
          expect(model.team_name).to            eq form.name
          expect(model.year).to                 eq form.year
          expect(model.car[:model]).to          eq form.car.model
          expect(model.car[:driver]).to         eq form.car.driver
          expect(model.car[:engine].power).to   eq form.car.engine.power
          expect(model.car[:engine].volume).to  eq form.car.engine.volume
          expect(chassis.suspension.front).to   eq form.chassis.suspension.front
          expect(chassis.suspension.rear).to    eq form.chassis.suspension.rear
          expect(chassis.brakes).to             eq form.chassis.brakes
        end

        it 'returns self' do
          expect(form.save_to_models(default: model, chassis: chassis)).to eql form
        end
      end

      context 'nested models are updated when they exists already' do
        before do
          model.car = { engine: SaveToModel::NestedForm::FewModels::Engine.new }
          chassis.suspension = SaveToModel::NestedForm::FewModels::Suspension.new

          form.name = 'Ferrari'
          form.year = 1950
          form.car.model = '340 F1'
          form.car.driver = 'Ascari'
          form.car.engine.power = 335
          form.car.engine.volume = 4.1
          form.chassis.suspension.front = 'independant'
          form.chassis.suspension.rear = 'de Dion'
          form.chassis.brakes = :drum

          form.save_to_models(default: model, chassis: chassis)
        end

        let(:form) { SaveToModel::NestedForm::FewModels::Form.new }

        it 'has all attributes correctly saved' do
          expect(model.team_name).to            eq form.name
          expect(model.year).to                 eq form.year
          expect(model.car[:model]).to          eq form.car.model
          expect(model.car[:driver]).to         eq form.car.driver
          expect(model.car[:engine].power).to   eq form.car.engine.power
          expect(model.car[:engine].volume).to  eq form.car.engine.volume
          expect(chassis.suspension.front).to   eq form.chassis.suspension.front
          expect(chassis.suspension.rear).to    eq form.chassis.suspension.rear
          expect(chassis.brakes).to             eq form.chassis.brakes
        end

        it 'returns self' do
          expect(form.save_to_models(default: model, chassis: chassis)).to eql form
        end
      end
    end

    describe 'explicit declaration of nested form classes' do
      module SaveToModel
        module NestedForm
          module FewModels
            class EngineForm < FormObj
              attribute :power
              attribute :volume
            end
            class CarForm < FormObj
              attribute :model
              attribute :engine, class: EngineForm, model_class: Engine
              attribute :driver
            end
            class ChassisForm < FormObj
              attribute :suspension, model_class: Suspension do
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

          form.save_to_models(default: model, chassis: chassis)
        end

        let(:form) { SaveToModel::NestedForm::FewModels::TeamForm.new }

        it 'has all attributes correctly saved' do
          expect(model.team_name).to            eq form.name
          expect(model.year).to                 eq form.year
          expect(model.car[:model]).to          eq form.car.model
          expect(model.car[:driver]).to         eq form.car.driver
          expect(model.car[:engine].power).to   eq form.car.engine.power
          expect(model.car[:engine].volume).to  eq form.car.engine.volume
          expect(chassis.suspension.front).to   eq form.chassis.suspension.front
          expect(chassis.suspension.rear).to    eq form.chassis.suspension.rear
          expect(chassis.brakes).to             eq form.chassis.brakes
        end

        it 'returns self' do
          expect(form.save_to_models(default: model, chassis: chassis)).to eql form
        end
      end

      context 'nested models are updated when they exists already' do
        before do
          model.car = { engine: SaveToModel::NestedForm::FewModels::Engine.new }
          chassis.suspension = SaveToModel::NestedForm::FewModels::Suspension.new

          form.name = 'Ferrari'
          form.year = 1950
          form.car.model = '340 F1'
          form.car.driver = 'Ascari'
          form.car.engine.power = 335
          form.car.engine.volume = 4.1
          form.chassis.suspension.front = 'independant'
          form.chassis.suspension.rear = 'de Dion'
          form.chassis.brakes = :drum

          form.save_to_models(default: model, chassis: chassis)
        end

        let(:form) { SaveToModel::NestedForm::FewModels::TeamForm.new }

        it 'has all attributes correctly saved' do
          expect(model.team_name).to            eq form.name
          expect(model.year).to                 eq form.year
          expect(model.car[:model]).to          eq form.car.model
          expect(model.car[:driver]).to         eq form.car.driver
          expect(model.car[:engine].power).to   eq form.car.engine.power
          expect(model.car[:engine].volume).to  eq form.car.engine.volume
          expect(chassis.suspension.front).to   eq form.chassis.suspension.front
          expect(chassis.suspension.rear).to    eq form.chassis.suspension.rear
          expect(chassis.brakes).to             eq form.chassis.brakes
        end

        it 'returns self' do
          expect(form.save_to_models(default: model, chassis: chassis)).to eql form
        end
      end
    end
  end
end
