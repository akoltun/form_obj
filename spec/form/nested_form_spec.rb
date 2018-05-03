RSpec.describe 'Nested Form Object' do
  shared_examples 'nested Form Object' do
    it 'has assigned values' do
      expect(form.name).to eq 'Ferrari'
      expect(form.year).to eq 1950
      expect(form.car.model).to eq '340 F1'
      expect(form.car.driver).to eq 'Ascari'
      expect(form.car.engine.power).to eq 335
      expect(form.car.engine.volume).to eq 4.1
    end

    it "doesn't have another attributes" do
      expect {
        form.another_attribute
      }.to raise_error NoMethodError

      expect {
        form.car.another_attribute
      }.to raise_error NoMethodError

      expect {
        form.car.engine.another_attribute
      }.to raise_error NoMethodError
    end
  end

  context 'Implicit declaration of form objects' do
    class NestedForm < FormObj::Form
      attribute :name
      attribute :year
      attribute :car do
        attribute :model
        attribute :driver
        attribute :engine do
          attribute :power
          attribute :volume
        end
      end
    end

    let(:form) { NestedForm.new }
    before do
      form.name = 'Ferrari'
      form.year = 1950
      form.car.model = '340 F1'
      form.car.driver = 'Ascari'
      form.car.engine.power = 335
      form.car.engine.volume = 4.1
    end

    it_behaves_like 'nested Form Object'
  end

  context 'Explicit declaration of form objects' do

    class NestedForm < FormObj::Form
      class EngineForm < FormObj::Form
        attribute :power
        attribute :volume
      end
      class CarForm < FormObj::Form
        attribute :model
        attribute :driver
        attribute :engine, class: EngineForm
      end
      class TeamForm < FormObj::Form
        attribute :name
        attribute :year
        attribute :car, class: CarForm
      end
    end
    let(:form) { NestedForm::TeamForm.new }

    context 'implicit creation of nested form instances (via dot notation)' do
      before do
        form.name = 'Ferrari'
        form.year = 1950
        form.car.model = '340 F1'
        form.car.driver = 'Ascari'
        form.car.engine.power = 335
        form.car.engine.volume = 4.1
      end

      it_behaves_like 'nested Form Object'
    end

    context 'explicit creation of nested form instances' do
      let(:car_form) { NestedForm::CarForm.new }
      let(:engine_form) { NestedForm::EngineForm.new }
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

      it_behaves_like 'nested Form Object'
    end
  end
end