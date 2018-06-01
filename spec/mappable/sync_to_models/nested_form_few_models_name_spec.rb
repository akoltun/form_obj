RSpec.describe 'sync_to_model: Nested Form Objects - Few Models - Name' do
  module SaveToModels
    class NestedFormName < FormObj::Form
      Engine      = Struct.new(:power, :volume)
      Suspension  = Struct.new(:front, :rear)
    end
  end

  let(:car) { { engine: SaveToModels::NestedFormName::Engine.new } }
  let(:suspension) { SaveToModels::NestedFormName::Suspension.new }

  let(:model) { Struct.new(:team_name, :year, :car).new }
  let(:chassis) { Struct.new(:suspension, :brakes).new }

  let(:sync_to_models) { form.sync_to_models(default: model, chassis: chassis) }

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

  shared_examples 'a form that can be saved' do
    it 'creates non-existent models and correctly saves all attributes' do
      expect(model.team_name).to            eq form.name
      expect(model.year).to                 eq form.year
      expect(model.car[:code]).to          eq form.car.code
      expect(model.car[:driver]).to         eq form.car.driver
      expect(model.car[:engine].power).to   eq form.car.engine.power
      expect(model.car[:engine].volume).to  eq form.car.engine.volume
      expect(chassis.suspension.front).to   eq form.chassis.suspension.front
      expect(chassis.suspension.rear).to    eq form.chassis.suspension.rear
      expect(chassis.brakes).to             eq form.chassis.brakes
    end

    it 'returns self' do
      expect(sync_to_models).to eql form
    end
  end

  context 'Implicit declaration of form object classes' do
    module SaveToModels
      class NestedFormName < FormObj::Form
        include FormObj::ModelMapper

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :car, model_hash: true do
          attribute :code
          attribute :engine, model_class: 'SaveToModels::NestedFormName::Engine' do
            attribute :power
            attribute :volume
          end
          attribute :driver
        end
        attribute :chassis, model_attribute: false, model: :chassis do
          attribute :suspension, model_class: 'SaveToModels::NestedFormName::Suspension' do
            attribute :front
            attribute :rear
          end
          attribute :brakes
        end
      end
    end

    let(:form) { SaveToModels::NestedFormName.new }

    context 'nested models are created when they do not exist yet' do
      include_context 'initialize form'
      before { sync_to_models }

      it_behaves_like 'a form that can be saved'
    end

    context 'nested models are updated when they exists already' do
      before do
        model.car = car
        chassis.suspension = suspension
      end

      include_context 'initialize form'
      before { sync_to_models }

      it_behaves_like 'a form that can be saved'

      it "doesn't create new nested models" do
        expect(model.car).to eql car
        expect(chassis.suspension).to eql suspension
      end
    end
  end

  context 'Explicit declaration of form object classes' do
    module SaveToModels
      class NestedFormName < FormObj::Form
        class EngineForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :power
          attribute :volume
        end
        class CarForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :code
          attribute :engine, class: EngineForm, model_class: 'SaveToModels::NestedFormName::Engine'
          attribute :driver
        end
        class ChassisForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :suspension, model_class: 'SaveToModels::NestedFormName::Suspension' do
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

    let(:form) { SaveToModels::NestedFormName::TeamForm.new }

    context 'nested models are created when they do not exist yet' do
      include_context 'initialize form'
      before { sync_to_models }

      it_behaves_like 'a form that can be saved'
    end

    context 'nested models are updated when they exists already' do
      before do
        model.car = car
        chassis.suspension = suspension
      end

      include_context 'initialize form'
      before { sync_to_models }

      it_behaves_like 'a form that can be saved'

      it "doesn't create new nested models" do
        expect(model.car).to eql car
        expect(chassis.suspension).to eql suspension
      end
    end
  end
end
