RSpec.describe 'Simple Form Object' do
  include_context 'renderable'

  class SimpleForm < FormObj::Form
    attribute :name
    attribute :year
  end

  let(:form) { SimpleForm.new }
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