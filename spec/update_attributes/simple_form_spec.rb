RSpec.describe 'update_attributes: Simpe Form Object' do
  include_context 'renderable'

  module UpdateAttributes
    class SimpleForm < FormObj
      attribute :name
      attribute :year
    end
  end

  let(:form) { UpdateAttributes::SimpleForm.new }
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
