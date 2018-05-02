class FormObj
  class Attribute
    attr_reader :name, :subform, :model, :model_attributes, :model_class

    def initialize(name, subform = false, model: :default, model_attribute: nil, model_class: nil, hash: false, array: false)
      @subform = subform
      @array = array
      @hash = hash

      @model_attributes = model_attribute === false ? [] : (model_attribute || name).to_s.split('.')
      @name = name.to_s.start_with?(':') ? name.to_s[1..-1] : name.to_s

      @model = model
      @model_class = model_class.is_a?(Enumerable) ? model_class : [model_class || (hash ? Hash : name.to_s.camelize)]
    end

    def hash?
      @hash
    end

    def array?
      @array
    end
  end
end
