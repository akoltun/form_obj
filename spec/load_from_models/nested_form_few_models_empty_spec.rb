RSpec.describe FormObj, concept: true do
  describe 'LoadFromModel: nested form - few models - empty' do

    let(:model) { Struct.new(:team_name, :year, :car).new('Ferrari', 1950, nil) }
    let(:chassis) { Struct.new(:suspension, :brakes).new(nil, :drum) }

    describe 'nested form' do
      module LoadFromModel
        module NestedForm
          module FewModels
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
      end

      let(:form) { LoadFromModel::NestedForm::FewModels::Form.new(default: model, chassis: chassis) }

      it 'has all attributes correctly set up' do
        expect(form.name).to eq model.team_name
        expect(form.year).to eq model.year
        expect(form.car.model).to be_nil
        expect(form.car.driver).to be_nil
        expect(form.car.engine.power).to be_nil
        expect(form.car.engine.volume).to be_nil
        expect(form.chassis.suspension.front).to be_nil
        expect(form.chassis.suspension.rear).to be_nil
        expect(form.chassis.brakes).to eq chassis.brakes
      end

      it 'returns self' do
        expect(form.load_from_models(default: model, chassis: chassis)).to eql form
      end
    end

    describe 'explicit declaration of nested form classes' do
      module LoadFromModel
        module NestedForm
          module FewModels
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
              attribute :chassis, class: ChassisForm, model_attribute: false, model: :chassis
            end
          end
        end
      end

      let(:form) { LoadFromModel::NestedForm::FewModels::TeamForm.new(default: model, chassis: chassis) }

      it 'has all attributes correctly set up' do
        expect(form.name).to eq model.team_name
        expect(form.year).to eq model.year
        expect(form.car.model).to be_nil
        expect(form.car.driver).to be_nil
        expect(form.car.engine.power).to be_nil
        expect(form.car.engine.volume).to be_nil
        expect(form.chassis.suspension.front).to be_nil
        expect(form.chassis.suspension.rear).to be_nil
        expect(form.chassis.brakes).to eq chassis.brakes
      end

      it 'returns self' do
        expect(form.load_from_models(default: model, chassis: chassis)).to eql form
      end
    end
  end
end