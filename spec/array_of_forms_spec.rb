RSpec.describe FormObj, concept: true do
  include_context 'renderable'

  subject do
    form_for form, url: '/form' do |f|
      concat f.text_field :name
      form.cars.each do |car|
        concat(f.fields_for(:cars, car, index: nil) do |fc|
          concat fc.text_field :model
          concat(fc.fields_for(:engine) do |fce|
            concat fce.text_field :power
            concat fce.text_field :volume
          end)
          concat fc.text_field :driver
        end)
      end
      concat f.text_field :year
    end
  end

  shared_examples 'rendered form' do
    it 'form_for renders input element for :name' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[name\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :year' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[year\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :model' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[cars\]\[\]\[model\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :driver' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[cars\]\[\]\[driver\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :power' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[cars\]\[\]\[engine\]\[power\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :volume' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[cars\]\[\]\[engine\]\[volume\]"( \w+="[^"]+")* \/>/
    end
  end

  describe 'array of nested forms' do

    module ArrayOfForms
      class Form < FormObj
        attribute :name
        attribute :year
        attribute :cars, array: true do
          attribute :model
          attribute :driver
          attribute :engine do
            attribute :power
            attribute :volume
          end
        end
      end
    end

    let(:form) { ArrayOfForms::Form.new }
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

    it { expect(form.cars.size).to eq 2 }
    it_behaves_like 'rendered form'
  end

  describe 'explicit declaration of nested forms in array' do

    module ArrayOfForms
      class EngineForm < FormObj
        attribute :power
        attribute :volume
      end
      class CarForm < FormObj
        attribute :model
        attribute :driver
        attribute :engine, class: EngineForm
      end
      class TeamForm < FormObj
        attribute :name
        attribute :year
        attribute :cars, array: true, class: CarForm
      end
    end

    context 'dot notation' do
      let(:form) { ArrayOfForms::TeamForm.new }
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

      it { expect(form.cars.size).to eq 2 }
      it_behaves_like 'rendered form'
    end

    context 'explicit class creation notation' do
      let(:form) { ArrayOfForms::TeamForm.new }
      before do
        engine1 = ArrayOfForms::EngineForm.new
        engine1.power = 335
        engine1.volume = 4.1

        car1 = ArrayOfForms::CarForm.new
        car1.model = '340 F1'
        car1.driver = 'Ascari'
        car1.engine = engine1

        engine2 = ArrayOfForms::EngineForm.new
        engine2.power = 300
        engine2.volume = 3.3

        car2 = ArrayOfForms::CarForm.new
        car2.model = '275 F1'
        car2.driver = 'Villoresi'
        car2.engine = engine2

        form.name = 'Ferrari'
        form.year = 1950
        form.cars << car1
        form.cars << car2
      end

      it { expect(form.cars.size).to eq 2 }
      it_behaves_like 'rendered form'
    end
  end
end