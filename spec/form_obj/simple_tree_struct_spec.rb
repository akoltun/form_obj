RSpec.describe 'Simple Form Object' do
  class SimpleForm < FormObj
    attribute :name
    attribute :year
  end

  let(:form) { SimpleForm.new }
  before do
    form.name = 'Ferrari'
    form.year = 1950
  end

  it 'has assigned values' do
    expect(form.name).to eq 'Ferrari'
    expect(form.year).to eq 1950
  end

  it "doesn't have another attributes" do
    expect {
      form.another_attribute
    }.to raise_error NoMethodError
  end
end