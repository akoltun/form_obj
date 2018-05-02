RSpec.describe 'update_attributes: Array of Form Objects' do
  let(:update_attributes) {
    form.update_attributes(
        name: 'McLaren',
        year: 1966,
        cars: [
            {
                model: 'M2B',
                driver: 'Bruce McLaren',
                engine: {
                    volume: 3.0
                }
            }, {
                model: 'M7A',
                driver: 'Denis Hulme',
                engine: {
                    power: 415,
                }
            }
        ],
        )
  }

  context 'Implicit declaration of form objects' do
    context 'primary_key specified on attribute level' do
      module UpdateAttributes
        module PrimaryKeyAttributeLevel
          class ImplicitArrayForm < FormObj
            attribute :name
            attribute :year
            attribute :cars, array: true do
              attribute :model, primary_key: true
              attribute :driver
              attribute :engine do
                attribute :power
                attribute :volume
              end
            end
          end
        end
      end

      let(:form) { UpdateAttributes::PrimaryKeyAttributeLevel::ImplicitArrayForm.new }

      context 'initial form elements and updated elements are different' do
        context 'form initially has no array elements' do
          before do
            form.name = 'Ferrari'
            form.year = 1950
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has less elements than updated data' do
          before do
            form.name = 'Ferrari'
            form.year = 1950

            car = form.cars.create
            car.model = '340 F1'
            car.driver = 'Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has the same quantity of elements as updated data' do
          before do
            form.name = 'Ferrari'
            form.year = 1950

            car = form.cars.create
            car.model = '340 F1'
            car.driver = 'Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1

            car = form.cars.create
            car.model = '275 F1'
            car.driver = 'Villoresi'
            car.engine.power = 300
            car.engine.volume = 3.3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has more elements than updated data' do
          before do
            form.name = 'Ferrari'
            form.year = 1950

            car = form.cars.create
            car.model = '340 F1'
            car.driver = 'Alberto Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1

            car = form.cars.create
            car.model = '275 F1'
            car.driver = 'Luigi Villoresi'
            car.engine.power = 300
            car.engine.volume = 3.3

            car = form.cars.create
            car.model = '375 F1'
            car.driver = 'Jose Gonzalez'
            car.engine.power = 350
            car.engine.volume = 4.5
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end
      end

      context 'initial form elements and updated elements have the same elements' do
        context 'form initially has one element which is included in the updated ones' do
          before do
            form.name = 'Ferrari'
            form.year = 1950

            car = form.cars.create
            car.model = 'M7A'
            car.driver = 'Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to eq 4.1
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has three elements one of which is included in the updated ones' do
          before do
            form.name = 'Ferrari'
            form.year = 1950

            car = form.cars.create
            car.model = '340 F1'
            car.driver = 'Alberto Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1

            car = form.cars.create
            car.model = 'M2B'
            car.driver = 'Luigi Villoresi'
            car.engine.power = 300
            car.engine.volume = 3.3

            car = form.cars.create
            car.model = '375 F1'
            car.driver = 'Jose Gonzalez'
            car.engine.power = 350
            car.engine.volume = 4.5
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  eq 300
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end
      end
    end

    context 'primary_key specified on form level' do
      module UpdateAttributes
        module PrimaryKeyFormLevel
          class ImplicitArrayForm < FormObj
            attribute :name
            attribute :year
            attribute :cars, array: true, primary_key: :model do
              attribute :model
              attribute :driver
              attribute :engine do
                attribute :power
                attribute :volume
              end
            end
          end
        end
      end

      let(:form) { UpdateAttributes::PrimaryKeyFormLevel::ImplicitArrayForm.new }

      context 'initial form elements and updated elements are different' do
        context 'form initially has no array elements' do
          before do
            form.name = 'Ferrari'
            form.year = 1950
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has less elements than updated data' do
          before do
            form.name = 'Ferrari'
            form.year = 1950

            car = form.cars.create
            car.model = '340 F1'
            car.driver = 'Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has the same quantity of elements as updated data' do
          before do
            form.name = 'Ferrari'
            form.year = 1950

            car = form.cars.create
            car.model = '340 F1'
            car.driver = 'Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1

            car = form.cars.create
            car.model = '275 F1'
            car.driver = 'Villoresi'
            car.engine.power = 300
            car.engine.volume = 3.3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has more elements than updated data' do
          before do
            form.name = 'Ferrari'
            form.year = 1950

            car = form.cars.create
            car.model = '340 F1'
            car.driver = 'Alberto Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1

            car = form.cars.create
            car.model = '275 F1'
            car.driver = 'Luigi Villoresi'
            car.engine.power = 300
            car.engine.volume = 3.3

            car = form.cars.create
            car.model = '375 F1'
            car.driver = 'Jose Gonzalez'
            car.engine.power = 350
            car.engine.volume = 4.5
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end
      end

      context 'initial form elements and updated elements have the same elements' do
        context 'form initially has one element which is included in the updated ones' do
          before do
            form.name = 'Ferrari'
            form.year = 1950

            car = form.cars.create
            car.model = 'M7A'
            car.driver = 'Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to eq 4.1
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has three elements one of which is included in the updated ones' do
          before do
            form.name = 'Ferrari'
            form.year = 1950

            car = form.cars.create
            car.model = '340 F1'
            car.driver = 'Alberto Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1

            car = form.cars.create
            car.model = 'M2B'
            car.driver = 'Luigi Villoresi'
            car.engine.power = 300
            car.engine.volume = 3.3

            car = form.cars.create
            car.model = '375 F1'
            car.driver = 'Jose Gonzalez'
            car.engine.power = 350
            car.engine.volume = 4.5
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  eq 300
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end
      end
    end
  end

  context 'Explicit declaration of form objects' do
    context 'primary_key specified on attribute level' do
      module UpdateAttributes
        module PrimaryKeyAttributeLevel
          module ExplicitArray
            class EngineForm < FormObj
              attribute :power
              attribute :volume
            end
            class CarForm < FormObj
              attribute :model, primary_key: true
              attribute :engine, class: EngineForm
              attribute :driver
            end
            class TeamForm < FormObj
              attribute :name
              attribute :cars, array: true, class: CarForm
              attribute :year
            end
          end
        end
      end

      let(:form) { UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::TeamForm.new }

      before do
        engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
        engine1.power = 335
        engine1.volume = 4.1

        car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
        car1.model = '340 F1'
        car1.driver = 'Ascari'
        car1.engine = engine1

        engine2 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
        engine2.power = 300
        engine2.volume = 3.3

        car2 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
        car2.model = '275 F1'
        car2.driver = 'Villoresi'
        car2.engine = engine2

        form.name = 'Ferrari'
        form.year = 1950
        form.cars << car1
        form.cars << car2
      end

      context 'initial form elements and updated elements are different' do
        context 'form initially has no array elements' do
          before do
            form.name = 'Ferrari'
            form.year = 1950
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has less elements than updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
            car1.model = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            form.name = 'Ferrari'
            form.year = 1950
            form.cars << car1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has the same quantity of elements as updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
            car1.model = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
            car2.model = '275 F1'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            form.name = 'Ferrari'
            form.year = 1950
            form.cars << car1
            form.cars << car2
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has more elements than updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
            car1.model = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
            car2.model = '275 F1'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            engine3 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
            engine3.power = 350
            engine3.volume = 4.5

            car3 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
            car3.model = '375 F1'
            car3.driver = 'Jose Gonzalez'
            car3.engine = engine3

            form.name = 'Ferrari'
            form.year = 1950
            form.cars << car1
            form.cars << car2
            form.cars << car3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end
      end

      context 'initial form elements and updated elements have the same elements' do
        context 'form initially has one element which is included in the updated ones' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
            car1.model = 'M7A'
            car1.driver = 'Ascari'
            car1.engine = engine1

            form.name = 'Ferrari'
            form.year = 1950
            form.cars << car1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to eq 4.1
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has three elements one of which is included in the updated ones' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
            car1.model = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
            car2.model = 'M2B'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            engine3 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::EngineForm.new
            engine3.power = 350
            engine3.volume = 4.5

            car3 = UpdateAttributes::PrimaryKeyAttributeLevel::ExplicitArray::CarForm.new
            car3.model = '375 F1'
            car3.driver = 'Jose Gonzalez'
            car3.engine = engine3

            form.name = 'Ferrari'
            form.year = 1950
            form.cars << car1
            form.cars << car2
            form.cars << car3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  eq 300
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end
      end
    end

    context 'primary_key specified on form level' do
      module UpdateAttributes
        module PrimaryKeyFormLevel
          module ExplicitArray
            class EngineForm < FormObj
              attribute :power
              attribute :volume
            end
            class CarForm < FormObj
              attribute :model
              attribute :engine, class: EngineForm
              attribute :driver
            end
            class TeamForm < FormObj
              attribute :name
              attribute :cars, array: true, class: CarForm, primary_key: :model
              attribute :year
            end
          end
        end
      end

      let(:form) { UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::TeamForm.new }

      before do
        engine1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
        engine1.power = 335
        engine1.volume = 4.1

        car1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
        car1.model = '340 F1'
        car1.driver = 'Ascari'
        car1.engine = engine1

        engine2 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
        engine2.power = 300
        engine2.volume = 3.3

        car2 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
        car2.model = '275 F1'
        car2.driver = 'Villoresi'
        car2.engine = engine2

        form.name = 'Ferrari'
        form.year = 1950
        form.cars << car1
        form.cars << car2
      end

      context 'initial form elements and updated elements are different' do
        context 'form initially has no array elements' do
          before do
            form.name = 'Ferrari'
            form.year = 1950
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has less elements than updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
            car1.model = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            form.name = 'Ferrari'
            form.year = 1950
            form.cars << car1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has the same quantity of elements as updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
            car1.model = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
            car2.model = '275 F1'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            form.name = 'Ferrari'
            form.year = 1950
            form.cars << car1
            form.cars << car2
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has more elements than updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
            car1.model = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
            car2.model = '275 F1'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            engine3 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
            engine3.power = 350
            engine3.volume = 4.5

            car3 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
            car3.model = '375 F1'
            car3.driver = 'Jose Gonzalez'
            car3.engine = engine3

            form.name = 'Ferrari'
            form.year = 1950
            form.cars << car1
            form.cars << car2
            form.cars << car3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end
      end

      context 'initial form elements and updated elements have the same elements' do
        context 'form initially has one element which is included in the updated ones' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
            car1.model = 'M7A'
            car1.driver = 'Ascari'
            car1.engine = engine1

            form.name = 'Ferrari'
            form.year = 1950
            form.cars << car1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  be_nil
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to eq 4.1
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end

        context 'form initially has three elements one of which is included in the updated ones' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
            car1.model = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
            car2.model = 'M2B'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            engine3 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::EngineForm.new
            engine3.power = 350
            engine3.volume = 4.5

            car3 = UpdateAttributes::PrimaryKeyFormLevel::ExplicitArray::CarForm.new
            car3.model = '375 F1'
            car3.driver = 'Jose Gonzalez'
            car3.engine = engine3

            form.name = 'Ferrari'
            form.year = 1950
            form.cars << car1
            form.cars << car2
            form.cars << car3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(form.name).to                  eq 'McLaren'
            expect(form.year).to                  eq 1966

            expect(form.cars.size).to             eq 2

            expect(form.cars[0].model).to         eq 'M2B'
            expect(form.cars[0].driver).to        eq 'Bruce McLaren'
            expect(form.cars[0].engine.power).to  eq 300
            expect(form.cars[0].engine.volume).to eq 3.0

            expect(form.cars[1].model).to         eq 'M7A'
            expect(form.cars[1].driver).to        eq 'Denis Hulme'
            expect(form.cars[1].engine.power).to  eq 415
            expect(form.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql form
          end
        end
      end
    end
  end
end