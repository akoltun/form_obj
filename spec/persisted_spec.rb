RSpec.describe FormObj, concept: true do
  describe 'persisted' do

    let(:model) { Struct.new(:name).new }

    module PersistedForm
      class Form < FormObj
        attribute :name
      end
    end

    it 'is not persisted after initialization' do
      expect(PersistedForm::Form.new.persisted?).to be_falsey
    end

    it 'becomes persisted creating from model' do
      expect(PersistedForm::Form.new(default: model).persisted?).to be_truthy
    end

    it 'becomes persisted after loading from model' do
      expect(PersistedForm::Form.new.load_from_model(model).persisted?).to be_truthy
    end

    it 'becomes persisted after loading from models' do
      expect(PersistedForm::Form.new.load_from_models(default: model).persisted?).to be_truthy
    end

    it 'becomes persisted after saving to model' do
      expect(PersistedForm::Form.new.save_to_model(model).persisted?).to be_truthy
    end

    it 'becomes persisted after saving to models' do
      expect(PersistedForm::Form.new.save_to_models(default: model).persisted?).to be_truthy
    end

    it 'becomes non persisted after updating attributes' do
      expect(PersistedForm::Form.new(default: model).update_attributes(name: 'new').persisted?).to be_falsey
    end

    it 'becomes non persisted after updating each attribute individually' do
      form = PersistedForm::Form.new(default: model)
      form.name = 'new'
      expect(form.persisted?).to be_falsey
    end
  end
end