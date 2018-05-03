RSpec.describe 'Persistence' do
  let(:model) { Struct.new(:name).new }

  class PersistableForm < FormObj::Form
    attribute :name
  end

  let(:form) { PersistableForm.new }

  it 'is not persisted after initialization' do
    expect(form.persisted?).to be_falsey
  end

  it '#saved returns self' do
    expect(form.saved).to eql form
  end

  it '#saved makes it persisted' do
    expect(form.saved.persisted?).to be_truthy
  end

  it 'becomes non persisted after updating attributes' do
    expect(form.saved.update_attributes(name: 'new').persisted?).to be_falsey
  end

  it 'becomes non persisted after updating each attribute individually' do
    form.saved
    form.name = 'new'
    expect(form.persisted?).to be_falsey
  end
end
