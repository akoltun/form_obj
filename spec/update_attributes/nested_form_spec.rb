RSpec.describe 'update_attributes: Nested Form Object' do
  shared_examples 'updated form' do
    let(:update_attributes) {
      form.update_attributes(
          name: 'McLaren',
          year: 1966,
          car: {
              model: 'M2B',
              driver: 'Bruce McLaren',
              engine: {
                  power: 300,
                  volume: 3.0
              }
          }
      )
    }

    it 'has all attributes correctly updated' do
      update_attributes

      expect(form.name).to              eq 'McLaren'
      expect(form.year).to              eq 1966
      expect(form.car.model).to         eq 'M2B'
      expect(form.car.driver).to        eq 'Bruce McLaren'
      expect(form.car.engine.power).to  eq 300
      expect(form.car.engine.volume).to eq 3.0
    end

    it 'returns self' do
      expect(update_attributes).to eql form
    end
  end

  describe 'Implicit declaration of form object classes' do
    module UpdateAttributes
      class ImplicitNestedForm < FormObj
        attribute :name
        attribute :car do
          attribute :model
          attribute :engine do
            attribute :power
            attribute :volume
          end
          attribute :driver
        end
        attribute :year
      end
    end

    let(:form) { UpdateAttributes::ImplicitNestedForm.new }

    context 'nested forms present already' do
      before do
        form.name = 'Ferrari'
        form.year = 1950
        form.car.model = '340 F1'
        form.car.driver = 'Ascari'
        form.car.engine.power = 335
        form.car.engine.volume = 4.1
      end

      it_behaves_like 'updated form'
    end

    context 'nested forms not present yet' do
      before do
        form.name = 'Ferrari'
        form.year = 1950
      end

      it_behaves_like 'updated form'
    end
  end

  context 'Explicit declaration of form object classes' do
    module UpdateAttributes
      module ExplicitNested
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
          attribute :car, class: CarForm
          attribute :year
        end
      end
    end
    let(:form) { UpdateAttributes::ExplicitNested::TeamForm.new }

    context 'nested forms present already' do
      context 'implicit creation of nested form object instances (via dot notation)' do
        before do
          form.name = 'Ferrari'
          form.year = 1950
          form.car.model = '340 F1'
          form.car.driver = 'Ascari'
          form.car.engine.power = 335
          form.car.engine.volume = 4.1
        end

        it_behaves_like 'updated form'
      end
      context 'explicit creation of nested form object instances' do
        let(:car_form) { UpdateAttributes::ExplicitNested::CarForm.new }
        let(:engine_form) { UpdateAttributes::ExplicitNested::EngineForm.new }
        before do
          engine_form.power = 335
          engine_form.volume = 4.1

          car_form.model = '340 F1'
          car_form.driver = 'Ascari'
          car_form.engine = engine_form

          form.name = 'Ferrari'
          form.year = 1950
          form.car = car_form
        end

        it_behaves_like 'updated form'
      end

    end

    context 'nested forms not present yet' do
      before do
        form.name = 'Ferrari'
        form.year = 1950
      end

      it_behaves_like 'updated form'
    end
  end
end