RSpec.describe 'load_from_model: Nested Form Objects - One Model' do
  let(:engine) { Struct.new(:power, :volume).new(335, 4.1) }
  let(:car) {{ code: '340 F1', driver: 'Ascari', engine: engine }}
  let(:suspension) { Struct.new(:front, :rear).new('independant', 'de Dion') }
  let(:model) { Struct.new(:team_name, :year, :car, :suspension, :brakes).new('Ferrari', 1950, car, suspension, :drum) }

  context 'Implicit declaration of form object classes' do
    module LoadFromModel
      class NestedForm < FormObj::Form
        include FormObj::Mappable

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :car, hash: true do
          attribute :code
          attribute :driver
          attribute :engine do
            attribute :power
            attribute :volume
          end
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

    let(:form) { LoadFromModel::NestedForm.new }

    it 'has all attributes correctly set up' do
      form.load_from_model(model)

      expect(form.name).to eq model.team_name
      expect(form.year).to eq model.year
      expect(form.car.code).to eq model.car[:code]
      expect(form.car.driver).to eq model.car[:driver]
      expect(form.car.engine.power).to eq model.car[:engine].power
      expect(form.car.engine.volume).to eq model.car[:engine].volume
      expect(form.chassis.suspension.front).to eq model.suspension.front
      expect(form.chassis.suspension.rear).to eq model.suspension.rear
      expect(form.chassis.brakes).to eq model.brakes
    end

    it 'returns self' do
      expect(form.load_from_model(model)).to eql form
    end
  end

  context 'Explicit declaration of form object classes' do
    module LoadFromModel
      class NestedForm < FormObj::Form
        class EngineForm < FormObj::Form
          include FormObj::Mappable

          attribute :power
          attribute :volume
        end
        class CarForm < FormObj::Form
          include FormObj::Mappable

          attribute :code
          attribute :engine, class: EngineForm
          attribute :driver
        end
        class ChassisForm < FormObj::Form
          include FormObj::Mappable

          attribute :suspension do
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

    let(:form) { LoadFromModel::NestedForm::TeamForm.new }

    it 'has all attributes correctly set up' do
      form.load_from_model(model)

      expect(form.name).to eq model.team_name
      expect(form.year).to eq model.year
      expect(form.car.code).to eq model.car[:code]
      expect(form.car.driver).to eq model.car[:driver]
      expect(form.car.engine.power).to eq model.car[:engine].power
      expect(form.car.engine.volume).to eq model.car[:engine].volume
      expect(form.chassis.suspension.front).to eq model.suspension.front
      expect(form.chassis.suspension.rear).to eq model.suspension.rear
      expect(form.chassis.brakes).to eq model.brakes
    end

    it 'returns self' do
      expect(form.load_from_model(model)).to eql form
    end
  end
end
