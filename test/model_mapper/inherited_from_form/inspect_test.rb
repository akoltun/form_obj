require "test_helper"

class ModelMapperInspectTest < Minitest::Test
  class EmptyStruct < FormObj::Form
    include FormObj::ModelMapper
  end
  class SimpleStruct < FormObj::Form
    include FormObj::ModelMapper

    attribute :name
    attribute :year
  end
  class NestedStruct < FormObj::Form
    include FormObj::ModelMapper

    attribute :name
    attribute :year
    attribute :car do
      attribute :code
      attribute :driver
    end
  end
  class ArrayStruct < FormObj::Form
    include FormObj::ModelMapper

    attribute :name
    attribute :year
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver
    end
  end

  def test_inspect_on_empty_struct
    assert_equal('ModelMapperInspectTest::EmptyStruct', EmptyStruct.inspect)
    assert_equal('#<ModelMapperInspectTest::EmptyStruct>', EmptyStruct.new.inspect)
  end

  def test_inspect_on_simple_struct
    assert_equal('ModelMapperInspectTest::SimpleStruct(name, year)', SimpleStruct.inspect)
    assert_equal('#<ModelMapperInspectTest::SimpleStruct name: nil, year: nil>', SimpleStruct.new.inspect)
    assert_equal('#<ModelMapperInspectTest::SimpleStruct name: "Ferrari", year: 1950>', SimpleStruct.new(name: 'Ferrari', year: 1950).inspect)
  end

  def test_inspect_on_nested_struct
    assert_equal('ModelMapperInspectTest::NestedStruct(name, year, car)', NestedStruct.inspect)
    assert_equal('#<ModelMapperInspectTest::NestedStruct name: nil, year: nil, car: #< code: nil, driver: nil>>', NestedStruct.new.inspect)
    assert_equal('#<ModelMapperInspectTest::NestedStruct name: "Ferrari", year: 1950, car: #< code: "275 F1", driver: "Ascari">>', NestedStruct.new(name: 'Ferrari', year: 1950, car: { code: '275 F1', driver: 'Ascari' }).inspect)
  end

  def test_inspect_on_array_struct
    assert_equal('ModelMapperInspectTest::ArrayStruct(name, year, cars)', ArrayStruct.inspect)
    assert_equal('#<ModelMapperInspectTest::ArrayStruct name: nil, year: nil, cars: []>', ArrayStruct.new.inspect)
    assert_equal('#<ModelMapperInspectTest::ArrayStruct name: "Ferrari", year: 1950, cars: [#< code: "275 F1", driver: "Ascari" marked_for_destruction>, #< code: "340 F1", driver: "Villoresi">]>', ArrayStruct.new(name: 'Ferrari', year: 1950, cars: [{ code: '275 F1', driver: 'Ascari' }, { code: '340 F1', driver: 'Villoresi' }]).update_attributes(cars: [{ code: '275 F1', _destroy: true }]).inspect)
  end
end