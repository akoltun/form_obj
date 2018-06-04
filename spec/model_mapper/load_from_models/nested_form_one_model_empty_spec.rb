RSpec.describe 'load_from_model: Nested Form Objects - One Empty Model' do
  let(:model) { Struct.new(:team_name, :year, :car, :suspension, :brakes).new('Ferrari', 1950, nil, nil, :drum) }

  before { form.car.engine.power = 100 }

  shared_examples 'a nested form' do
    it 'has all attributes correctly set up' do
      form.load_from_model(model)

      expect(form.name).to eq model.team_name
      expect(form.year).to eq model.year
      expect(form.car.code).to be_nil
      expect(form.car.driver).to be_nil
      expect(form.car.engine.power).to be_nil
      expect(form.car.engine.volume).to be_nil
      expect(form.chassis.suspension.front).to be_nil
      expect(form.chassis.suspension.rear).to be_nil
      expect(form.chassis.brakes).to eq :drum
    end

    it 'returns self' do
      expect(form.load_from_model(model)).to eql form
    end
  end

  context 'Implicit declaration of form object classes' do
    module LoadFromModelEmpty
      class NestedForm < FormObj::Form
        include FormObj::ModelMapper

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :car, model_hash: true do
          attribute :code
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

    let(:form) { LoadFromModelEmpty::NestedForm.new }

    it_behaves_like 'a nested form'
  end

  context 'Explicit declaration of form object classes' do
    module LoadFromModelEmpty
      class NestedForm < FormObj::Form
        class EngineForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :power
          attribute :volume
        end
        class CarForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :code
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
          attribute :chassis, class: ChassisForm, model_attribute: false
        end
      end
    end

    let(:form) { LoadFromModelEmpty::NestedForm::TeamForm.new }

    it_behaves_like 'a nested form'
  end
end