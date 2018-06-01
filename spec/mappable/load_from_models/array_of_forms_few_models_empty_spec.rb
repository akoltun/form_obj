RSpec.describe 'load_from_models: Array of Form Objects - Few Empty Models' do
  let(:colour) { Struct.new(:name, :rgb) }

  module LoadFromModelsEmpty
    class ArrayForm < FormObj::Form
      class Model < ::Array
        attr_accessor :team_name, :year, :cars, :finance
      end
    end
  end

  let(:model) { LoadFromModelsEmpty::ArrayForm::Model.new }
  before do
    model.team_name = 'Ferrari'
    model.year = 1950

    model.push(colour.new('red', 0xFF0000), colour.new('green', 0x00FF00), colour.new('blue', 0x0000FF))
  end

  shared_examples 'a form of arrays' do
    it 'has all attributes correctly set up' do
      form.load_from_models(default: model, chassis: nil)

      expect(form.name).to eq model.team_name
      expect(form.year).to eq model.year

      expect(form.cars).to be_a FormObj::Array
      expect(form.cars.size).to eq 0

      expect(form.sponsors).to be_a FormObj::Array
      expect(form.sponsors.size).to eq 0

      expect(form.chassis).to be_a FormObj::Array
      expect(form.chassis.size).to eq 0

      expect(form.colours).to be_a FormObj::Array
      expect(form.colours.size).to eq 3

      expect(form.colours[0].name).to eq model[0].name
      expect(form.colours[0].rgb).to  eq model[0].rgb

      expect(form.colours[1].name).to eq model[1].name
      expect(form.colours[1].rgb).to  eq model[1].rgb

      expect(form.colours[2].name).to eq model[2].name
      expect(form.colours[2].rgb).to  eq model[2].rgb
    end

    it 'returns self' do
      expect(form.load_from_models(default: model, chassis: nil)).to eql form
    end
  end

  context 'Implicit declaration of form object classes' do
    module LoadFromModelsEmpty
      class ArrayForm < FormObj::Form
        include FormObj::Mappable

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :cars, array: true do
          attribute :code
          attribute :driver
          attribute :engine do
            attribute :power
            attribute :volume
          end
        end
        attribute :sponsors, array: true, model_attribute: 'finance.:sponsors' do
          attribute :title
          attribute :money
        end
        attribute :chassis, array: true, hash: true, model: :chassis do
          attribute :suspension do
            attribute :front
            attribute :rear
          end
          attribute :brakes
        end
        attribute :colours, array: true, model_attribute: false do
          attribute :name
          attribute :rgb
        end
      end
    end

    let(:form) { LoadFromModelsEmpty::ArrayForm.new }

    it_behaves_like 'a form of arrays'
  end

  context 'Explicit declaration of form object classes' do
    module LoadFromModelsEmpty
      class ArrayForm < FormObj::Form
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
        class SponsorForm < FormObj::Form
          include FormObj::Mappable

          attribute :title
          attribute :money
        end
        class SuspensionForm < FormObj::Form
          include FormObj::Mappable

          attribute :front
          attribute :rear
        end
        class ChassisForm < FormObj::Form
          include FormObj::Mappable

          attribute :suspension, class: SuspensionForm
          attribute :brakes
        end
        class ColourForm < FormObj::Form
          include FormObj::Mappable

          attribute :name
          attribute :rgb
        end
        class TeamForm < FormObj::Form
          include FormObj::Mappable

          attribute :name, model_attribute: :team_name
          attribute :year
          attribute :cars, array: true, class: CarForm
          attribute :sponsors, array: true, model_attribute: 'finance.:sponsors', class: SponsorForm
          attribute :chassis, array: true, hash: true, class: ChassisForm, model: :chassis
          attribute :colours, array: true, model_attribute: false, class: ColourForm
        end
      end
    end

    let(:form) { LoadFromModelsEmpty::ArrayForm::TeamForm.new }

    it_behaves_like 'a form of arrays'
  end
end