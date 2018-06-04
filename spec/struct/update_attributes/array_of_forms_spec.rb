RSpec.describe 'update_attributes: Array of Struct Objects' do
  let(:update_attributes) {
    struct.update_attributes(
        name: 'McLaren',
        year: 1966,
        cars: [
            {
                code: 'M2B',
                driver: 'Bruce McLaren',
                engine: {
                    volume: 3.0
                }
            }, {
                code: 'M7A',
                driver: 'Denis Hulme',
                engine: {
                    power: 415,
                }
            }
        ],
        )
  }

  context 'Implicit declaration of struct objects' do
    shared_examples 'implicitly declared struct object' do
      context 'initial struct elements and updated elements are different' do
        context 'struct initially has no array elements' do
          before do
            struct.name = 'Ferrari'
            struct.year = 1950
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has less elements than updated data' do
          before do
            struct.name = 'Ferrari'
            struct.year = 1950

            car = struct.cars.create
            car.code = '340 F1'
            car.driver = 'Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has the same quantity of elements as updated data' do
          before do
            struct.name = 'Ferrari'
            struct.year = 1950

            car = struct.cars.create
            car.code = '340 F1'
            car.driver = 'Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1

            car = struct.cars.create
            car.code = '275 F1'
            car.driver = 'Villoresi'
            car.engine.power = 300
            car.engine.volume = 3.3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has more elements than updated data' do
          before do
            struct.name = 'Ferrari'
            struct.year = 1950

            car = struct.cars.create
            car.code = '340 F1'
            car.driver = 'Alberto Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1

            car = struct.cars.create
            car.code = '275 F1'
            car.driver = 'Luigi Villoresi'
            car.engine.power = 300
            car.engine.volume = 3.3

            car = struct.cars.create
            car.code = '375 F1'
            car.driver = 'Jose Gonzalez'
            car.engine.power = 350
            car.engine.volume = 4.5
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end
      end

      context 'initial struct elements and updated elements have the same elements' do
        context 'struct initially has one element which is included in the updated ones' do
          before do
            struct.name = 'Ferrari'
            struct.year = 1950

            car = struct.cars.create
            car.code = 'M7A'
            car.driver = 'Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to eq 4.1
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has three elements one of which is included in the updated ones' do
          before do
            struct.name = 'Ferrari'
            struct.year = 1950

            car = struct.cars.create
            car.code = '340 F1'
            car.driver = 'Alberto Ascari'
            car.engine.power = 335
            car.engine.volume = 4.1

            car = struct.cars.create
            car.code = 'M2B'
            car.driver = 'Luigi Villoresi'
            car.engine.power = 300
            car.engine.volume = 3.3

            car = struct.cars.create
            car.code = '375 F1'
            car.driver = 'Jose Gonzalez'
            car.engine.power = 350
            car.engine.volume = 4.5
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  eq 300
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end
      end
    end

    context 'primary_key specified on attribute level' do
      module UpdateAttributes
        module PrimaryKeyAttributeLevel
          class ArrayStruct < FormObj::Struct
            attribute :name
            attribute :year
            attribute :cars, array: true do
              attribute :code, primary_key: true
              attribute :driver
              attribute :engine do
                attribute :power
                attribute :volume
              end
            end
          end
        end
      end

      let(:struct) { UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct.new }

      it_behaves_like 'implicitly declared struct object'
    end

    context 'primary_key specified on struct level' do
      module UpdateAttributes
        module PrimaryKeyStructLevel
          class ArrayStruct < FormObj::Struct
            attribute :name
            attribute :year
            attribute :cars, array: true, primary_key: :code do
              attribute :code
              attribute :driver
              attribute :engine do
                attribute :power
                attribute :volume
              end
            end
          end
        end
      end

      let(:struct) { UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct.new }

      it_behaves_like 'implicitly declared struct object'
    end
  end

  context 'Explicit declaration of struct objects' do
    context 'primary_key specified on attribute level' do
      module UpdateAttributes
        module PrimaryKeyAttributeLevel
          class ArrayStruct < FormObj::Struct
            class EngineStruct < FormObj::Struct
              attribute :power
              attribute :volume
            end
            class CarStruct < FormObj::Struct
              attribute :code, primary_key: true
              attribute :engine, class: EngineStruct
              attribute :driver
            end
            class TeamStruct < FormObj::Struct
              attribute :name
              attribute :cars, array: true, class: CarStruct
              attribute :year
            end
          end
        end
      end

      let(:struct) { UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::TeamStruct.new }

      before do
        engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
        engine1.power = 335
        engine1.volume = 4.1

        car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
        car1.code = '340 F1'
        car1.driver = 'Ascari'
        car1.engine = engine1

        engine2 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
        engine2.power = 300
        engine2.volume = 3.3

        car2 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
        car2.code = '275 F1'
        car2.driver = 'Villoresi'
        car2.engine = engine2

        struct.name = 'Ferrari'
        struct.year = 1950
        struct.cars << car1
        struct.cars << car2
      end

      context 'initial struct elements and updated elements are different' do
        context 'struct initially has no array elements' do
          before do
            struct.name = 'Ferrari'
            struct.year = 1950
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has less elements than updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
            car1.code = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            struct.name = 'Ferrari'
            struct.year = 1950
            struct.cars << car1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has the same quantity of elements as updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
            car1.code = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
            car2.code = '275 F1'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            struct.name = 'Ferrari'
            struct.year = 1950
            struct.cars << car1
            struct.cars << car2
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has more elements than updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
            car1.code = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
            car2.code = '275 F1'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            engine3 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
            engine3.power = 350
            engine3.volume = 4.5

            car3 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
            car3.code = '375 F1'
            car3.driver = 'Jose Gonzalez'
            car3.engine = engine3

            struct.name = 'Ferrari'
            struct.year = 1950
            struct.cars << car1
            struct.cars << car2
            struct.cars << car3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end
      end

      context 'initial struct elements and updated elements have the same elements' do
        context 'struct initially has one element which is included in the updated ones' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
            car1.code = 'M7A'
            car1.driver = 'Ascari'
            car1.engine = engine1

            struct.name = 'Ferrari'
            struct.year = 1950
            struct.cars << car1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to eq 4.1
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has three elements one of which is included in the updated ones' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
            car1.code = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
            car2.code = 'M2B'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            engine3 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::EngineStruct.new
            engine3.power = 350
            engine3.volume = 4.5

            car3 = UpdateAttributes::PrimaryKeyAttributeLevel::ArrayStruct::CarStruct.new
            car3.code = '375 F1'
            car3.driver = 'Jose Gonzalez'
            car3.engine = engine3

            struct.name = 'Ferrari'
            struct.year = 1950
            struct.cars << car1
            struct.cars << car2
            struct.cars << car3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  eq 300
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end
      end
    end

    context 'primary_key specified on struct level' do
      module UpdateAttributes
        module PrimaryKeyStructLevel
          class ArrayStruct < FormObj::Struct
            class EngineStruct < FormObj::Struct
              attribute :power
              attribute :volume
            end
            class CarStruct < FormObj::Struct
              attribute :code
              attribute :engine, class: EngineStruct
              attribute :driver
            end
            class TeamStruct < FormObj::Struct
              attribute :name
              attribute :cars, array: true, class: CarStruct, primary_key: :code
              attribute :year
            end
          end
        end
      end

      let(:struct) { UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::TeamStruct.new }

      before do
        engine1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
        engine1.power = 335
        engine1.volume = 4.1

        car1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
        car1.code = '340 F1'
        car1.driver = 'Ascari'
        car1.engine = engine1

        engine2 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
        engine2.power = 300
        engine2.volume = 3.3

        car2 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
        car2.code = '275 F1'
        car2.driver = 'Villoresi'
        car2.engine = engine2

        struct.name = 'Ferrari'
        struct.year = 1950
        struct.cars << car1
        struct.cars << car2
      end

      context 'initial struct elements and updated elements are different' do
        context 'struct initially has no array elements' do
          before do
            struct.name = 'Ferrari'
            struct.year = 1950
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has less elements than updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
            car1.code = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            struct.name = 'Ferrari'
            struct.year = 1950
            struct.cars << car1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has the same quantity of elements as updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
            car1.code = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
            car2.code = '275 F1'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            struct.name = 'Ferrari'
            struct.year = 1950
            struct.cars << car1
            struct.cars << car2
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has more elements than updated data' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
            car1.code = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
            car2.code = '275 F1'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            engine3 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
            engine3.power = 350
            engine3.volume = 4.5

            car3 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
            car3.code = '375 F1'
            car3.driver = 'Jose Gonzalez'
            car3.engine = engine3

            struct.name = 'Ferrari'
            struct.year = 1950
            struct.cars << car1
            struct.cars << car2
            struct.cars << car3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end
      end

      context 'initial struct elements and updated elements have the same elements' do
        context 'struct initially has one element which is included in the updated ones' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
            car1.code = 'M7A'
            car1.driver = 'Ascari'
            car1.engine = engine1

            struct.name = 'Ferrari'
            struct.year = 1950
            struct.cars << car1
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  be_nil
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to eq 4.1
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end

        context 'struct initially has three elements one of which is included in the updated ones' do
          before do
            engine1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
            engine1.power = 335
            engine1.volume = 4.1

            car1 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
            car1.code = '340 F1'
            car1.driver = 'Ascari'
            car1.engine = engine1

            engine2 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
            engine2.power = 300
            engine2.volume = 3.3

            car2 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
            car2.code = 'M2B'
            car2.driver = 'Villoresi'
            car2.engine = engine2

            engine3 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::EngineStruct.new
            engine3.power = 350
            engine3.volume = 4.5

            car3 = UpdateAttributes::PrimaryKeyStructLevel::ArrayStruct::CarStruct.new
            car3.code = '375 F1'
            car3.driver = 'Jose Gonzalez'
            car3.engine = engine3

            struct.name = 'Ferrari'
            struct.year = 1950
            struct.cars << car1
            struct.cars << car2
            struct.cars << car3
          end

          it 'has all attributes correctly updated' do
            update_attributes

            expect(struct.name).to                  eq 'McLaren'
            expect(struct.year).to                  eq 1966

            expect(struct.cars.size).to             eq 2

            expect(struct.cars[0].code).to         eq 'M2B'
            expect(struct.cars[0].driver).to        eq 'Bruce McLaren'
            expect(struct.cars[0].engine.power).to  eq 300
            expect(struct.cars[0].engine.volume).to eq 3.0

            expect(struct.cars[1].code).to         eq 'M7A'
            expect(struct.cars[1].driver).to        eq 'Denis Hulme'
            expect(struct.cars[1].engine.power).to  eq 415
            expect(struct.cars[1].engine.volume).to be_nil
          end

          it 'returns self' do
            expect(update_attributes).to eql struct
          end
        end
      end
    end
  end
end