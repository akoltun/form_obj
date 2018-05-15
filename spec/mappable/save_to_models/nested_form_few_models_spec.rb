RSpec.describe 'save_to_models: Nested Form Objects - Few Models' do
  module SaveToModels
    class NestedForm < FormObj::Form
      Engine      = Struct.new(:power, :volume)
      Suspension  = Struct.new(:front, :rear)
    end
  end

  let(:car) { { engine: SaveToModels::NestedForm::Engine.new } }
  let(:suspension) { SaveToModels::NestedForm::Suspension.new }

  let(:model) { Struct.new(:team_name, :year, :car).new }
  let(:chassis) { Struct.new(:suspension, :brakes).new }

  let(:save_to_models) { form.save_to_models(default: model, chassis: chassis) }

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

  shared_examples 'a form that can be saved' do
    it 'creates non-existent models and correctly saves all attributes' do
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
      expect(save_to_models).to eql form
    end
  end

  context 'Implicit declaration of form object classes' do
    module SaveToModels
      class NestedForm < FormObj::Form
        include FormObj::Mappable

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

    let(:form) { SaveToModels::NestedForm.new }

    context 'nested models are created when they do not exist yet' do
      include_context 'initialize form'
      before { save_to_models }

      it_behaves_like 'a form that can be saved'
    end

    context 'nested models are updated when they exists already' do
      before do
        model.car = car
        chassis.suspension = suspension
      end

      include_context 'initialize form'
      before { save_to_models }

      it_behaves_like 'a form that can be saved'

      it "doesn't create new nested models" do
        expect(model.car).to eql car
        expect(chassis.suspension).to eql suspension
      end
    end
  end

  context 'Explicit declaration of form object classes' do
    module SaveToModels
      class NestedForm < FormObj::Form
        class EngineForm < FormObj::Form
          include FormObj::Mappable

          attribute :power
          attribute :volume
        end
        class CarForm < FormObj::Form
          include FormObj::Mappable

          attribute :model
          attribute :engine, class: EngineForm, model_class: Engine
          attribute :driver
        end
        class ChassisForm < FormObj::Form
          include FormObj::Mappable

          attribute :suspension, model_class: Suspension do
            attribute :front
            attribute :rear
          end
          attribute :brakes
        end
        class TeamForm < FormObj::Form
          include FormObj::Mappable

          attribute :name, model_attribute: :team_name
          attribute :car, class: CarForm, hash: true
          attribute :year
          attribute :chassis, class: ChassisForm, model_attribute: false, model: :chassis
        end
      end
    end

    let(:form) { SaveToModels::NestedForm::TeamForm.new }

    context 'nested models are created when they do not exist yet' do
      include_context 'initialize form'
      before { save_to_models }

      it_behaves_like 'a form that can be saved'
    end

    context 'nested models are updated when they exists already' do
      before do
        model.car = car
        chassis.suspension = suspension
      end

      include_context 'initialize form'
      before { save_to_models }

      it_behaves_like 'a form that can be saved'

      it "doesn't create new nested models" do
        expect(model.car).to eql car
        expect(chassis.suspension).to eql suspension
      end
    end
  end
end
