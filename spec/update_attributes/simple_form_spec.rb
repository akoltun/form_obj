RSpec.describe 'FormObj - update attributes', concept: true do
  include_context 'renderable'

  describe 'simple form' do

    module UpdateAttributes
      module SimpleForm
        class Form < FormObj
          attribute :name
          attribute :year
        end
      end
    end

    let(:form) { UpdateAttributes::SimpleForm::Form.new }
    before do
      form.name = 'Ferrari'
      form.year = 1950

      form.update_attributes(name: 'McLaren', year: 1966)
    end

    it 'has all attributes correctly updated' do
      expect(form.name).to eq 'McLaren'
      expect(form.year).to eq 1966
    end

    it 'returns self' do
      expect(form.update_attributes(name: 'McLaren', year: 1966)).to eql form
    end
  end
end