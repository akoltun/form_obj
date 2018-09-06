require "test_helper"

class StructCompareClassWithInheritedWithDifferentDefaultValueTest < Minitest::Test
  class Team < FormObj::Struct # Default primary key is id
    attribute :name, default: 'Ferrari'
    attribute :year
    attribute :top_cars, array: true, primary_key: :code, default: [{ code: '275 F1', driver: 'Ascari' }, { code: '340 F1', driver: 'Villoresi' }] do
      attribute :code
      attribute :driver
    end
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver, default: 'Ascari'
    end
    attribute :first_colour, default: { name: :red, rgb: 0xFF0000 } do
      attribute :name
      attribute :rgb
    end
    attribute :second_colour, array: true, primary_key: :name do
      attribute :name, default: :white
      attribute :rgb
    end
  end

  class Team1 < Team # Default primary key is id
    attribute :name, default: 'McLaren'
  end

  class Team2 < Team # Default primary key is id
    attribute :top_cars, array: true, primary_key: :code, default: [{ code: '275 F1', driver: 'Hunt' }, { code: '340 F1', driver: 'Villoresi' }] do
      attribute :code
      attribute :driver
    end
  end

  class Team3 < Team # Default primary key is id
    attribute :cars, array: true, primary_key: :code do
      attribute :code
      attribute :driver, default: 'Villoresi'
    end
  end

  class Team4 < Team # Default primary key is id
    attribute :first_colour, default: { name: :blue, rgb: 0xFF0000 } do
      attribute :name
      attribute :rgb
    end
  end

  class Team5 < Team # Default primary key is id
    attribute :second_colour, array: true, primary_key: :name do
      attribute :name, default: :green
      attribute :rgb
    end
  end

  def test_different_default_on_root_level
    refute(Team.eql? Team1)
    refute(Team === Team1)
    refute(Team == Team1)

    refute(Team.eql? Team1.new)
    refute(Team === Team1.new)
    refute(Team == Team1.new)
  end

  def test_different_array_default
    refute(Team.eql? Team2)
    refute(Team === Team2)
    refute(Team == Team2)

    refute(Team.eql? Team2.new)
    refute(Team === Team2.new)
    refute(Team == Team2.new)
  end

  def test_different_array_attribute_default
    refute(Team.eql? Team3)
    refute(Team === Team3)
    refute(Team == Team3)

    refute(Team.eql? Team3.new)
    refute(Team === Team3.new)
    refute(Team == Team3.new)
  end

  def test_different_nested_default
    refute(Team.eql? Team4)
    refute(Team === Team4)
    refute(Team == Team4)

    refute(Team.eql? Team4.new)
    refute(Team === Team4.new)
    refute(Team == Team4.new)
  end

  def test_different_nested_attribute_default
    refute(Team.eql? Team5)
    refute(Team === Team5)
    refute(Team == Team5)

    refute(Team.eql? Team5.new)
    refute(Team === Team5.new)
    refute(Team == Team5.new)
  end
end
