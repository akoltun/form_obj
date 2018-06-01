RSpec.describe 'to_model_hash: Array of Form Objects - One Model' do
  subject { form.to_model_hash }

  shared_context 'initialize form' do
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
    end
  end

  shared_examples 'hashable form' do
    it 'correctly presents all attributes in the hash' do
      is_expected.to eq Hash[
                            team_name: 'Ferrari',
                            year: 1950,
                            cars: [{
                                       car_code: '340 F1',
                                       driver: 'Ascari',
                                       engine: {
                                           power: 335,
                                           volume: 4.1
                                       }
                                   }, {
                                       car_code: '275 F1',
                                       driver: 'Villoresi',
                                       engine: {
                                           power: 300,
                                           volume: 3.3
                                       }
                                   }],
                            finance: {
                                sponsors: [{
                                               title: 'Shell',
                                               money: 1000000
                                           }, {
                                               title: 'Pirelli',
                                               money: 500000
                                           }]
                            },
                            chassis: [{
                                          id: 1,
                                          suspension: {
                                              front: 'independant',
                                              rear: 'de Dion'
                                          },
                                          brakes: :drum
                                      }, {
                                          id: 2,
                                          suspension: {
                                              front: 'dependant',
                                              rear: 'de Lion'
                                          },
                                          brakes: :disc
                                      }],
                            self: [{
                                       name: 'red',
                                       rgb: 0xFF0000
                                   }, {
                                       name: 'green',
                                       rgb: 0x00FF00
                                   }, {
                                       name: 'blue',
                                       rgb: 0x0000FF
                                   }]
                        ]
    end
  end

  context 'Implicit declaration of form objects' do
    module ToModelHash
      class ArrayForm < FormObj::Form
        include FormObj::Mappable

        attribute :name, model_attribute: :team_name
        attribute :year
        attribute :cars, array: true, primary_key: :code do
          attribute :code, model_attribute: :car_code
          attribute :driver
          attribute :engine do
            attribute :power
            attribute :volume
          end
        end
        attribute :sponsors, array: true, model_attribute: 'finance.:sponsors', primary_key: :title do
          attribute :title
          attribute :money
        end
        attribute :chassis, array: true, hash: true do
          attribute :id
          attribute :suspension do
            attribute :front
            attribute :rear
          end
          attribute :brakes
        end
        attribute :colours, array: true, model_attribute: false, primary_key: :name do
          attribute :name
          attribute :rgb
        end
      end
    end

    let(:form) { ToModelHash::ArrayForm.new }

    include_context 'initialize form'
    it_behaves_like 'hashable form'
  end

  context 'Explicit declaration of form objects' do
    module ToModelHash
      class ArrayForm < FormObj::Form
        class EngineForm < FormObj::Form
          include FormObj::Mappable

          attribute :power
          attribute :volume
        end
        class CarForm < FormObj::Form
          include FormObj::Mappable

          attribute :code, model_attribute: :car_code
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

          attribute :id
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
          attribute :cars, array: true, class: CarForm, primary_key: :code
          attribute :sponsors, array: true, model_attribute: 'finance.:sponsors', class: SponsorForm, primary_key: :title
          attribute :chassis, array: true, hash: true, class: ChassisForm
          attribute :colours, array: true, model_attribute: false, class: ColourForm, primary_key: :name
        end
      end
    end

    let(:form) { ToModelHash::ArrayForm::TeamForm.new }

    include_context 'initialize form'
    it_behaves_like 'hashable form'
  end
end