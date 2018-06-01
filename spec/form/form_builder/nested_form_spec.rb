RSpec.describe 'Nested Form Object' do
  include_context 'renderable'

  subject do
    form_for form, url: '/form' do |f|
      concat f.text_field :name
      concat f.text_field :year
      concat(f.fields_for(:car) do |fc|
        concat fc.text_field :code
        concat fc.text_field :driver
        concat(fc.fields_for(:engine) do |fce|
          concat fce.text_field :power
          concat fce.text_field :volume
        end)
      end)
    end
  end

  shared_examples 'rendered form' do
    it 'form_for renders input element for :name' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[name\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :year' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[year\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :code' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[car\]\[code\]"( \w+="[^"]+")* \/>/
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

  context 'Implicit declaration of form objects' do

    class NestedForm < FormObj::Form
      attribute :name
      attribute :year
      attribute :car do
        attribute :code
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
      form.car.code = '340 F1'
      form.car.driver = 'Ascari'
      form.car.engine.power = 335
      form.car.engine.volume = 4.1
    end

    it_behaves_like 'rendered form'
  end

  context 'Explicit declaration of form objects' do

    class NestedForm < FormObj::Form
      class EngineForm < FormObj::Form
        attribute :power
        attribute :volume
      end
      class CarForm < FormObj::Form
        attribute :code
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

    context 'implicit creation of nested form object instances (via dot notation)' do
      before do
        form.name = 'Ferrari'
        form.year = 1950
        form.car.code = '340 F1'
        form.car.driver = 'Ascari'
        form.car.engine.power = 335
        form.car.engine.volume = 4.1
      end

      it_behaves_like 'rendered form'
    end

    context 'explicit creation of nested form object instances' do
      let(:car_form) { NestedForm::CarForm.new }
      let(:engine_form) { NestedForm::EngineForm.new }
      before do
        engine_form.power = 335
        engine_form.volume = 4.1

        car_form.code = '340 F1'
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