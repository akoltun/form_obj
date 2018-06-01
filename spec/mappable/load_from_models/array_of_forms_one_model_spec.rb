RSpec.describe 'load_from_model: Array of Form Objects - One Model' do
  let(:engine) { Struct.new(:power, :volume) }
  let(:car) { Struct.new(:code, :driver, :engine) }
  let(:cars) {[
      car.new('340 F1', 'Ascari', engine.new(335, 4.1)),
      car.new('275 F1', 'Villoresi', engine.new(300, 3.3)),
  ]}

  let(:sponsor) { Struct.new(:title, :money) }
  let(:finance) {{ sponsors: [sponsor.new('Shell', 1000000), sponsor.new('Pirelli', 500000)] }}

  let(:suspension) { Struct.new(:front, :rear) }
  let(:chassis) {[
      { suspension: suspension.new('independant', 'de Dion'), brakes: :drum },
      { suspension: suspension.new('dependant', 'de Dion'), brakes: :disc }
  ]}

  let(:colour) { Struct.new(:name, :rgb) }

  module LoadFromModel
    class ArrayForm < FormObj::Form
      class Model < ::Array
        attr_accessor :team_name, :year, :cars, :finance, :chassis
      end
    end
  end

  let(:model) { LoadFromModel::ArrayForm::Model.new }
  before do
    model.team_name = 'Ferrari'
    model.year = 1950
    model.cars = cars
    model.finance = finance
    model.chassis = chassis

    model.push(colour.new('red', 0xFF0000), colour.new('green', 0x00FF00), colour.new('blue', 0x0000FF))

    5.times { form.cars.create }
  end

  shared_examples 'a form of arrays' do
    it 'has all attributes correctly set up' do
      form.load_from_model(model)

      expect(form.name).to eq model.team_name
      expect(form.year).to eq model.year

      expect(form.cars).to be_a FormObj::Mappable::Array
      expect(form.cars.size).to eq 2

      expect(form.cars[0].code).to          eq model.cars[0].code
      expect(form.cars[0].driver).to        eq model.cars[0].driver
      expect(form.cars[0].engine.power).to  eq model.cars[0].engine.power
      expect(form.cars[0].engine.volume).to eq model.cars[0].engine.volume

      expect(form.cars[1].code).to          eq model.cars[1].code
      expect(form.cars[1].driver).to        eq model.cars[1].driver
      expect(form.cars[1].engine.power).to  eq model.cars[1].engine.power
      expect(form.cars[1].engine.volume).to eq model.cars[1].engine.volume

      expect(form.sponsors).to be_a FormObj::Mappable::Array
      expect(form.sponsors.size).to eq 2

      expect(form.sponsors[0].title).to eq model.finance[:sponsors][0].title
      expect(form.sponsors[0].money).to eq model.finance[:sponsors][0].money

      expect(form.sponsors[1].title).to eq model.finance[:sponsors][1].title
      expect(form.sponsors[1].money).to eq model.finance[:sponsors][1].money

      expect(form.chassis).to be_a FormObj::Mappable::Array
      expect(form.chassis.size).to eq 2

      expect(form.chassis[0].suspension.front).to eq model.chassis[0][:suspension].front
      expect(form.chassis[0].suspension.rear).to  eq model.chassis[0][:suspension].rear
      expect(form.chassis[0].brakes).to           eq model.chassis[0][:brakes]

      expect(form.chassis[1].suspension.front).to eq model.chassis[1][:suspension].front
      expect(form.chassis[1].suspension.rear).to  eq model.chassis[1][:suspension].rear
      expect(form.chassis[1].brakes).to           eq model.chassis[1][:brakes]

      expect(form.colours).to be_a FormObj::Mappable::Array
      expect(form.colours.size).to eq 3

      expect(form.colours[0].name).to eq model[0].name
      expect(form.colours[0].rgb).to  eq model[0].rgb

      expect(form.colours[1].name).to eq model[1].name
      expect(form.colours[1].rgb).to  eq model[1].rgb

      expect(form.colours[2].name).to eq model[2].name
      expect(form.colours[2].rgb).to  eq model[2].rgb
    end

    it 'returns self' do
      expect(form.load_from_model(model)).to eql form
    end
  end

  context 'Implicit declaration of form object classes' do
    module LoadFromModel
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
        attribute :chassis, array: true, hash: true do
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

    let(:form) { LoadFromModel::ArrayForm.new }

    it_behaves_like 'a form of arrays'
  end

  context 'Explicit declaration of form object classes' do
    module LoadFromModel
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
            attribute :chassis, array: true, hash: true, class: ChassisForm
            attribute :colours, array: true, model_attribute: false, class: ColourForm
          end
      end
    end

    let(:form) { LoadFromModel::ArrayForm::TeamForm.new }

    it_behaves_like 'a form of arrays'
  end
end