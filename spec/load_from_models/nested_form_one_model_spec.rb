RSpec.describe FormObj, concept: true do
  describe 'LoadFromModel: nested form - one model' do

    let(:engine) { Struct.new(:power, :volume).new(335, 4.1) }
    let(:car) {{ model: '340 F1', driver: 'Ascari', engine: engine }}
    let(:suspension) { Struct.new(:front, :rear).new('independant', 'de Dion') }
    let(:model) { Struct.new(:team_name, :year, :car, :suspension, :brakes).new('Ferrari', 1950, car, suspension, :drum) }

    describe 'nested form' do
      module LoadFromModel
        module NestedForm
          module OneModel
            class Form < FormObj
              attribute :name, model_attribute: :team_name
              attribute :year
              attribute :car, hash: true do
                attribute :model
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

      let(:form) { LoadFromModel::NestedForm::OneModel::Form.new(default: model) }

      it 'has all attributes correctly set up' do
        expect(form.name).to eq model.team_name
        expect(form.year).to eq model.year
        expect(form.car.model).to eq model.car[:model]
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

    describe 'explicit declaration of nested form classes' do
      module LoadFromModel
        module NestedForm
          module OneModel
            class EngineForm < FormObj
              attribute :power
              attribute :volume
            end
            class CarForm < FormObj
              attribute :model
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

      let(:form) { LoadFromModel::NestedForm::OneModel::TeamForm.new(default: model) }

      it 'has all attributes correctly set up' do
        expect(form.name).to eq model.team_name
        expect(form.year).to eq model.year
        expect(form.car.model).to eq model.car[:model]
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
end