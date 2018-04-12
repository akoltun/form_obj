RSpec.describe FormObj, concept: true do
  include_context 'renderable'

  describe 'simple form' do

    module SimpleForm
      class Form < FormObj
        attribute :name
        attribute :year
      end
    end

    let(:form) { SimpleForm::Form.new }
    before do
      form.name = 'Ferrari'
      form.year = 1950
    end

    subject do
      form_for form, url: '/form' do |f|
        concat f.text_field :name
        concat f.text_field :year
      end
    end

    it 'form_for renders input element for :name' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[name\]"( \w+="[^"]+")* \/>/
    end

    it 'form_for renders input element for :year' do
      is_expected.to match /<input( \w+="[^"]+")* name="\w+\[year\]"( \w+="[^"]+")* \/>/
    end
  end
end