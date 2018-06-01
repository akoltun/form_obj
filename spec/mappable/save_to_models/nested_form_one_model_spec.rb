RSpec.describe 'save_to_model: Nested Form Objects - One Model' do
  module SaveToModel
    class NestedForm < FormObj::Form
      include FormObj::Mappable

      Engine = Struct.new(:power, :volume)
      Suspension = Struct.new(:front, :rear)
    end
  end

  let(:engine) { SaveToModel::NestedForm::Engine.new }
  let(:suspension) { SaveToModel::NestedForm::Suspension.new }
  let(:model) { Struct.new(:team_name, :year, :car, :suspension, :brakes).new }

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
      expect(model.car[:code]).to           eq form.car.code
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

  context 'Implicit declaration of form object classes' do
    module SaveToModel
      class NestedForm < FormObj::Form
        include FormObj::Mappable

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :car, hash: true do
          attribute :code
          attribute :engine, model_class: Engine do
            attribute :power
            attribute :volume
          end
          attribute :driver
        end
        attribute :chassis, model_attribute: false do
          attribute :suspension, model_class: Suspension do
            attribute :front
            attribute :rear
          end
          attribute :brakes
        end
      end
    end

    let(:form) { SaveToModel::NestedForm.new }

    context 'nested models are created when they do not exist yet' do
      include_context 'initialize form'
      before { form.save_to_model(model) }

      it_behaves_like 'a form that can be saved'
    end

    context 'nested models are updated when they exists already' do
      let(:car) {{ engine: engine }}
      before do
        model.car = car
        model.suspension = suspension
      end

      include_context 'initialize form'
      before { form.save_to_model(model) }

      it_behaves_like 'a form that can be saved'

      it "doesn't create new nested models" do
        expect(model.car).to eql car
        expect(model.suspension).to eql suspension
      end
    end
  end

  context 'Explicit declaration of form object classes' do
    module SaveToModel
      class NestedForm < FormObj::Form
        include FormObj::Mappable

        class EngineForm < FormObj::Form
          include FormObj::Mappable

          attribute :power
          attribute :volume
        end
        class CarForm < FormObj::Form
          include FormObj::Mappable

          attribute :code
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
          attribute :chassis, class: ChassisForm, model_attribute: false
        end
      end
    end

    let(:form) { SaveToModel::NestedForm::TeamForm.new }

    context 'nested models are created when they do not exist yet' do
      include_context 'initialize form'
      before { form.save_to_model(model) }

      it_behaves_like 'a form that can be saved'
    end

    context 'nested models are updated when they exists already' do
      let(:car) {{ engine: engine }}
      before do
        model.car = car
        model.suspension = suspension
      end

      include_context 'initialize form'
      before { form.save_to_model(model) }

      it_behaves_like 'a form that can be saved'

      it "doesn't create new nested models" do
        expect(model.car).to eql car
        expect(model.suspension).to eql suspension
      end
    end
  end
end