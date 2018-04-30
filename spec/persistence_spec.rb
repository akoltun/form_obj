RSpec.describe 'Persistence' do
  let(:model) { Struct.new(:name).new }

  class PersistableForm < FormObj
    attribute :name
  end

  it 'is not persisted after initialization' do
    expect(PersistableForm.new.persisted?).to be_falsey
  end

  it 'becomes persisted creating from model' do
    expect(PersistableForm.new.load_from_model(model).persisted?).to be_truthy
  end

  it 'becomes persisted after loading from model' do
    expect(PersistableForm.new.load_from_model(model).persisted?).to be_truthy
  end

  it 'becomes persisted after loading from models' do
    expect(PersistableForm.new.load_from_models(default: model).persisted?).to be_truthy
  end

  it 'becomes persisted after saving to model' do
    expect(PersistableForm.new.save_to_model(model).persisted?).to be_truthy
  end

  it 'becomes persisted after saving to models' do
    expect(PersistableForm.new.save_to_models(default: model).persisted?).to be_truthy
  end

  it 'becomes non persisted after updating attributes' do
    expect(PersistableForm.new.load_from_model(model).update_attributes(name: 'new').persisted?).to be_falsey
  end

  it 'becomes non persisted after updating each attribute individually' do
    form = PersistableForm.new.load_from_model(model)
    form.name = 'new'
    expect(form.persisted?).to be_falsey
  end
end
