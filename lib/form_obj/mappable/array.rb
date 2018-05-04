module FormObj
  module Mappable
    class Array < FormObj::Array
      def initialize(item_class, hash: false)
        @hash = hash
        super(item_class)
      end

      def load_from_models(models)
        clear
        (models[:default] || []).each do |model|
          create.load_from_models(models.merge(default: model))
        end
        self
      end
    end
  end
end
