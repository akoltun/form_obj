RSpec.describe 'sync_to_model: Array of Form Objects - One Model' do
  module SaveToModel
    class ArrayForm < FormObj::Form
      Engine = Struct.new(:power, :volume, :secret)
      Suspension = Struct.new(:front, :rear, :secret)
      Car = Struct.new(:car_code, :driver, :engine, :secret)
      Sponsor = Struct.new(:title, :money, :secret)
      Colour = Struct.new(:name, :rgb, :secret)

      class Model < ::Array
        attr_accessor :team_name, :year, :cars, :finance, :chassis, :drivers_championships
      end
    end
  end

  let(:model) { SaveToModel::ArrayForm::Model.new }

  shared_context 'init form and save to models' do
    before do
      form.name = 'Ferrari'
      form.year = 1950

      car = form.cars.create
      car.code = '340 F1'
      car.driver = 'Ascari'
      car.engine.power = 335
      car.engine.volume = 4.1

      car = form.cars.create
      car.code = '275 F1'
      car.driver = 'Villoresi'
      car.engine.power = 300
      car.engine.volume = 3.3

      sponsor = form.sponsors.create
      sponsor.title = 'Shell'
      sponsor.money = 1000000

      sponsor = form.sponsors.create
      sponsor.title = 'Pirelli'
      sponsor.money = 500000

      chassis = form.chassis.create
      chassis.id = 1
      chassis.suspension.front = 'independant'
      chassis.suspension.rear = 'de Dion'
      chassis.brakes = :drum

      chassis = form.chassis.create
      chassis.id = 2
      chassis.suspension.front = 'dependant'
      chassis.suspension.rear = 'de Lion'
      chassis.brakes = :disc

      colour = form.colours.create
      colour.name = 'red'
      colour.rgb = 0xFF0000

      colour = form.colours.create
      colour.name = 'green'
      colour.rgb = 0x00FF00

      colour = form.colours.create
      colour.name = 'blue'
      colour.rgb = 0x0000FF

      drivers_championship = form.drivers_championships.create
      drivers_championship.driver = 'Ascari'
      drivers_championship.year = 1952

      drivers_championship = form.drivers_championships.create
      drivers_championship.driver = 'Hawthorn'
      drivers_championship.year = 1958

      constructors_championship = form.constructors_championships.create
      constructors_championship.year = 1961

      constructors_championship = form.constructors_championships.create
      constructors_championship.year = 1964

      expect {
        form.sync_to_model(model)
      }.not_to raise_error
    end
  end

  shared_examples 'a form of arrays' do
    it 'has all attributes correctly saved' do
      expect(model.team_name).to            eq 'Ferrari'
      expect(model.year).to                 eq 1950

      expect(model.cars.size).to eq 2
      expect(model.cars.map { |c| c[:car_code] }).to match_array(['340 F1', '275 F1'])

      car = model.cars.find { |c| c[:car_code] == '340 F1' }
      expect(car.driver).to             eq 'Ascari'
      expect(car.engine.power).to       eq 335
      expect(car.engine.volume).to      eq 4.1

      car = model.cars.find { |c| c[:car_code] == '275 F1' }
      expect(car.driver).to             eq 'Villoresi'
      expect(car.engine.power).to       eq 300
      expect(car.engine.volume).to      eq 3.3

      expect(model.finance[:sponsors].size).to    eq 2

      expect(model.finance[:sponsors][0].title).to eq 'Shell'
      expect(model.finance[:sponsors][0].money).to eq 1000000

      expect(model.finance[:sponsors][1].title).to eq 'Pirelli'
      expect(model.finance[:sponsors][1].money).to eq 500000

      expect(model.chassis.size).to eq 2

      expect(model.chassis[0][:id]).to eq 1
      expect(model.chassis[0][:suspension].front).to eq 'independant'
      expect(model.chassis[0][:suspension].rear).to eq 'de Dion'
      expect(model.chassis[0][:brakes]).to eq :drum

      expect(model.chassis[1][:id]).to eq 2
      expect(model.chassis[1][:suspension].front).to eq 'dependant'
      expect(model.chassis[1][:suspension].rear).to eq 'de Lion'
      expect(model.chassis[1][:brakes]).to eq :disc

      expect(model.size).to eq 3

      expect(model[0].name).to eq 'red'
      expect(model[0].rgb).to eq 0xFF0000

      expect(model[1].name).to eq 'green'
      expect(model[1].rgb).to eq 0x00FF00

      expect(model[2].name).to eq 'blue'
      expect(model[2].rgb).to eq 0x0000FF

      expect(model.drivers_championships).to be_nil
    end

    it 'returns self' do
      expect(form.sync_to_model(model)).to eql form
    end
  end

  context 'Implicit declaration of form object classes' do
    module SaveToModel
      class ArrayForm < FormObj::Form
        include FormObj::ModelMapper

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :cars, array: true, model_class: Car, primary_key: :code do
          attribute :code, model_attribute: :car_code
          attribute :driver
          attribute :engine, model_class: Engine do
            attribute :power
            attribute :volume
          end
        end
        attribute :sponsors, array: true, model_attribute: 'finance.:sponsors', model_class: [Hash, Sponsor], primary_key: :title do
          attribute :title
          attribute :money
        end
        attribute :chassis, array: true, model_hash: true do
          attribute :id
          attribute :suspension, model_class: Suspension do
            attribute :front
            attribute :rear
          end
          attribute :brakes
        end
        attribute :colours, array: true, model_nesting: false, model_class: Colour, primary_key: :name do
          attribute :name
          attribute :rgb
        end
        attribute :drivers_championships, array: true, model_attribute: false do
          attribute :driver
          attribute :year
        end
        attribute :constructors_championships, array: true, model_attribute: false do
          attribute :year
        end
      end
    end

    let(:form) { SaveToModel::ArrayForm.new }

    context 'completely empty model' do
      include_context 'init form and save to models'

      it_behaves_like 'a form of arrays'

      it 'creates all new nested model objects' do
        expect(model.cars[0].secret).to be_nil
        expect(model.cars[1].secret).to be_nil

        expect(model.finance[:sponsors][0].secret).to be_nil
        expect(model.finance[:sponsors][1].secret).to be_nil

        expect(model.chassis[0]).not_to have_key :secret
        expect(model.chassis[1]).not_to have_key :secret

        expect(model.chassis[0][:suspension].secret).to be_nil
        expect(model.chassis[1][:suspension].secret).to be_nil

        expect(model[0].secret).to be_nil
        expect(model[1].secret).to be_nil
        expect(model[2].secret).to be_nil
      end
    end

    context 'prefilled model' do
      before do
        model.team_name = 'McLaren'
        model.year = 1966

        model.cars = [
            SaveToModel::ArrayForm::Car.new('275 F1', 'Villo', SaveToModel::ArrayForm::Engine.new(200, 2.0, 101), 1),
            SaveToModel::ArrayForm::Car.new('M2B', 'Bruce McLaren', SaveToModel::ArrayForm::Engine.new(300, 3.0, 102), 2),
            SaveToModel::ArrayForm::Car.new('M7A', 'Denis Hulme', SaveToModel::ArrayForm::Engine.new(415, 4.3, 103), 3),
        ]

        model.finance = { sponsors: [
            SaveToModel::ArrayForm::Sponsor.new('Total', 250, 11),
            SaveToModel::ArrayForm::Sponsor.new('BP', 260, 12),
            SaveToModel::ArrayForm::Sponsor.new('Shell', 260, 13),
        ] }

        model.chassis = [
            { suspension: SaveToModel::ArrayForm::Suspension.new('independant', 'very old', 21), brakes: :disc, secret: 31, id: 1 },
            { suspension: SaveToModel::ArrayForm::Suspension.new('old', 'very old', 22), brakes: :drum, secret: 32, id: 3 },
        ]

        model[0] = SaveToModel::ArrayForm::Colour.new('red', 0xFF0000, 301)
        model[1] = SaveToModel::ArrayForm::Colour.new('green', 0x00FF00, 302)
        model[2] = SaveToModel::ArrayForm::Colour.new('blue', 0x0000FF, 303)
      end

      include_context 'init form and save to models'

      it_behaves_like 'a form of arrays'

      it "doesn't create new model objects if they exists" do
        expect(model.cars[0].secret).to eq 1
        expect(model.cars[1].secret).to be_nil

        expect(model.finance[:sponsors][0].secret).to eq 13
        expect(model.finance[:sponsors][1].secret).to be_nil

        expect(model.chassis[0][:secret]).to eq 31
        expect(model.chassis[1]).not_to have_key :secret

        expect(model.chassis[0][:suspension].secret).to eq 21
        expect(model.chassis[1][:suspension].secret).to be_nil

        expect(model[0].secret).to eq 301
        expect(model[1].secret).to eq 302
        expect(model[2].secret).to eq 303
      end
    end
  end

  context 'Explicit declaration of form object classes' do
    module SaveToModel
      class ArrayForm < FormObj::Form
        class EngineForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :power
          attribute :volume
        end
        class CarForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :code, model_attribute: :car_code
          attribute :engine, class: EngineForm, model_class: Engine
          attribute :driver
        end
        class SponsorForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :title
          attribute :money
        end
        class SuspensionForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :front
          attribute :rear
        end
        class ChassisForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :id
          attribute :suspension, class: SuspensionForm, model_class: Suspension
          attribute :brakes
        end
        class ColourForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :name
          attribute :rgb
        end
        class DriversChampionshipForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :driver
          attribute :year
        end
        class ConstructorsChampionshipForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :year
        end
        class TeamForm < FormObj::Form
          include FormObj::ModelMapper

          attribute :name, model_attribute: :team_name
          attribute :year
          attribute :cars, array: true, class: CarForm, model_class: Car, primary_key: :code
          attribute :sponsors, array: true, model_attribute: 'finance.:sponsors', class: SponsorForm, model_class: [Hash, Sponsor], primary_key: :title
          attribute :chassis, array: true, model_hash: true, class: ChassisForm
          attribute :colours, array: true, model_nesting: false, class: ColourForm, model_class: Colour, primary_key: :name
          attribute :drivers_championships, array: true, class: DriversChampionshipForm, model_attribute: false
          attribute :constructors_championships, array: true, class: ConstructorsChampionshipForm, model_attribute: false
        end
      end
    end

    let(:form) { SaveToModel::ArrayForm::TeamForm.new }

    context 'completely empty model' do
      include_context 'init form and save to models'

      it_behaves_like 'a form of arrays'

      it 'creates all new nested model objects' do
        expect(model.cars[0].secret).to be_nil
        expect(model.cars[1].secret).to be_nil

        expect(model.finance[:sponsors][0].secret).to be_nil
        expect(model.finance[:sponsors][1].secret).to be_nil

        expect(model.chassis[0]).not_to have_key :secret
        expect(model.chassis[1]).not_to have_key :secret

        expect(model.chassis[0][:suspension].secret).to be_nil
        expect(model.chassis[1][:suspension].secret).to be_nil

        expect(model[0].secret).to be_nil
        expect(model[1].secret).to be_nil
        expect(model[2].secret).to be_nil
      end
    end

    context 'prefilled model' do
      before do
        model.team_name = 'McLaren'
        model.year = 1966

        model.cars = [
            SaveToModel::ArrayForm::Car.new('275 F1', 'Villo', SaveToModel::ArrayForm::Engine.new(200, 2.0, 101), 1),
            SaveToModel::ArrayForm::Car.new('M2B', 'Bruce McLaren', SaveToModel::ArrayForm::Engine.new(300, 3.0, 102), 2),
            SaveToModel::ArrayForm::Car.new('M7A', 'Denis Hulme', SaveToModel::ArrayForm::Engine.new(415, 4.3, 103), 3),
        ]

        model.finance = { sponsors: [
            SaveToModel::ArrayForm::Sponsor.new('Total', 250, 11),
            SaveToModel::ArrayForm::Sponsor.new('BP', 260, 12),
            SaveToModel::ArrayForm::Sponsor.new('Shell', 260, 13),
        ] }

        model.chassis = [
            { suspension: SaveToModel::ArrayForm::Suspension.new('independant', 'very old', 21), brakes: :disc, id: 1, secret: 31 },
            { suspension: SaveToModel::ArrayForm::Suspension.new('old', 'very old', 22), brakes: :drum, id: 3, secret: 32 },
        ]

        model[0] = SaveToModel::ArrayForm::Colour.new('red', 0xFF0000, 301)
        model[1] = SaveToModel::ArrayForm::Colour.new('green', 0x00FF00, 302)
        model[2] = SaveToModel::ArrayForm::Colour.new('blue', 0x0000FF, 303)
      end

      include_context 'init form and save to models'

      it_behaves_like 'a form of arrays'

      it "doesn't create new model objects if they exists" do
        expect(model.cars[0].secret).to eq 1
        expect(model.cars[1].secret).to be_nil

        expect(model.finance[:sponsors][0].secret).to eq 13
        expect(model.finance[:sponsors][1].secret).to be_nil

        expect(model.chassis[0][:secret]).to eq 31
        expect(model.chassis[1]).not_to have_key :secret

        expect(model.chassis[0][:suspension].secret).to eq 21
        expect(model.chassis[1][:suspension].secret).to be_nil

        expect(model[0].secret).to eq 301
        expect(model[1].secret).to eq 302
        expect(model[2].secret).to eq 303
      end
    end
  end
end
