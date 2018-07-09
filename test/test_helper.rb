$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "form_obj"

require "minitest/autorun"

# Used in sync_to_model_test & sync_to_models_test
Suspension = Struct.new(:front, :rear)

# Used in sync_to_model_test & sync_to_models_test
module ModelMarkableForDestruction
  def mark_for_destruction
    @marked_for_destruction = true
  end

  def marked_for_destruction?
    @marked_for_destruction
  end
end

# Used in sync_to_model_test & sync_to_models_test
class ArrayWithWhere < Array
  def where(condition)
    key = condition.keys.first
    values = condition.values.first

    select { |item| values.include?(item.is_a?(::Hash) ? item[key] : item.send(key)) }
  end
end
