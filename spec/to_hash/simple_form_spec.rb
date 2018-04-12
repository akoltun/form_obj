RSpec.describe FormObj, concept: true do
  describe 'simple form - to_hash' do
    module SimpleForm
      module ToHash
        class Form < FormObj
          attribute :name
          attribute :year
        end
      end
    end

    let(:form) { SimpleForm::ToHash::Form.new }
    before do
      form.name = 'Ferrari'
      form.year = 1950
    end

    subject { form.to_hash }

    it 'correctly presents all attributes in the hash' do
      is_expected.to eq Hash[
                            name: 'Ferrari',
                            year: 1950
                        ]
    end
  end
end