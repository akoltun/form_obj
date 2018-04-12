RSpec.describe FormObj, concept: true do
  include_context 'renderable'

  subject do
    form_for form, url: '/form' do |f|
      concat f.text_field :name
      concat(f.fields_for(:car) do |fc|
        concat fc.text_field :model
        concat(fc.fields_for(:engine) do |fce|
          concat fce.text_field :power
          concat fce.text_field :volume
        end)
        concat fc.text_field :driver
      end)
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
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[car\]\[model\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :driver' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[car\]\[driver\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :power' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[car\]\[engine\]\[power\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :volume' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[car\]\[engine\]\[volume\]"( \w+="[^"]+")* \/>/
    end
  end

  describe 'nested form' do

    module NestedForm
      class Form < FormObj
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

    let(:form) { NestedForm::Form.new }
    before do
      form.name = 'Ferrari'
      form.year = 1950
      form.car.model = '340 F1'
      form.car.driver = 'Ascari'
      form.car.engine.power = 335
      form.car.engine.volume = 4.1
    end

    it_behaves_like 'rendered form'
  end

  describe 'explicit declaration of each nested form' do

    module NestedForm
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

    context 'dot notation' do
      let(:form) { NestedForm::TeamForm.new }
      before do
        form.name = 'Ferrari'
        form.year = 1950
        form.car.model = '340 F1'
        form.car.driver = 'Ascari'
        form.car.engine.power = 335
        form.car.engine.volume = 4.1
      end

      it_behaves_like 'rendered form'
    end

    context 'explicit class creation notation' do
      let(:form) { NestedForm::TeamForm.new }
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

      it_behaves_like 'rendered form'
    end
  end
end