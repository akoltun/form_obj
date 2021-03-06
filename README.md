# FormObj

[![Gem Version](https://badge.fury.io/rb/form_obj.svg)](https://badge.fury.io/rb/form_obj)
[![Build Status](https://travis-ci.com/akoltun/form_obj.svg?branch=master)](https://travis-ci.com/akoltun/form_obj)

Form Object allows to define a complicated data structure (using nesting, arrays) and use it with Rails-compatible form builders.
A Form Object can be serialized and deserialized to a model and/or a hash.

## Compatibility and Dependency Requirements

Ruby: 2.2.8+
ActiveSupport: 3.2+
ActiveModel: 3.2+

The gem is tested against all ruby versions and all versions of its dependencies 
except ActiveSupport and ActiveModel version 4.0.x because they requires Minitest 4 which is not compatible with Minitest 5.

This gem follows [Semantic Versioning](https://semver.org/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'form_obj'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install form_obj

## Usage

Class `FormObj::Struct` allows to describe complicated data structure, to update it with `update_attributes` method and to get its hash representation with `to_hash` method.

Class `FormObj::Form` inherits from `FormObj::Struct` and adds form builder compatibility and includes ActiveModel validations.

Module `FormObj::ModelMapper` being included into `FormObj::Form` descendants allows to map a form object to a model 
in order to be able to exchange attributes value between them:
* load attributes value from the model,
* sync attributes value to the model, 
* represent a form object as a model hash (similar to the `to_hash` method but using the
model attributes name) and 
* copy errors from the model(s) to the from object. 

### Table of Contents

1. [`FormObj::Struct`](#1-formobjstruct)
   1. [Nesting `FormObj::Struct`](#11-nesting-formobjstruct)
   2. [Array of `FormObj::Struct`](#12-array-of-formobjstruct)
   3. [Serialize `FormObj::Struct` to Hash](#13-serialize-formobjstruct-to-hash)
2. [`FormObj::Form`](#2-formobjform)
   1. [`FormObj::Form` Validation](#21-formobjform-validation)
   2. [`FormObj::Form` Persistence](#22-formobjform-persistence)
   3. [Non-Existent Attributes in `FormObj::Form` `update_attributes` Do Not Raise By Default](23-non-existent-attributes-in-formobjform-update_attributes-do-not-raise-by-default)
   4. [Delete from Array of `FormObj::Form` via `update_attributes` method](#24-delete-from-array-of-formobjform-via-update_attributes-method)
   5. [Using `FormObj::Form` in Form Builder](#25-using-formobjform-in-form-builder)
3. [`FormObj::ModelMapper`](#3-formobjmodelmapper)
   1. [`load_from_model` - Initialize Form Object from Model](#31-load_from_model---initialize-form-object-from-model)
   2. [`load_from_models` - Initialize Form Object from Few Models](#32-load_from_models---initialize-form-object-from-few-models)
   3. [Do Not Map Certain Attribute](#33-do-not-map-certain-attribute)
   4. [Do Not Map Certain Attribute For Reading From Model](#34-do-not-map-certain-attribute-for-reading-from-model)
   5. [Do Not Map Certain Attribute For Writing to Model](#35-do-not-map-certain-attribute-for-writing-to-model)
   6. [Map Nested Form Objects](#36-map-nested-form-objects)
   7. [Map Nested Form Object to Parent Level Model](#37-map-nested-form-object-to-parent-level-model)
   8. [Map Nested Form Objects to A Hash Model](#38-map-nested-form-object-to-a-hash-model)
   9. [Map Array of Nested Form Objects](#39-map-array-of-nested-form-objects)
   10. [Map Array of Nested Form Objects to Nested Array of Nested Models](#310-map-array-of-nested-form-objects-to-nested-array-of-nested-models)
   11. [Default Implementation of Loading of Array of Models](#311-default-implementation-of-loading-of-array-of-models)
   12. [Custom Implementation of Loading of Array of Models](#312-custom-implementation-of-loading-of-array-of-models)
   13. [Sync Form Object to Model(s)](#313-sync-form-object-to-models)
   14. [Sync Array of Nested Form Objects to Model(s)](#314-sync-array-of-nested-form-objects-to-models)
   15. [Sync Array of Nested Form Objects to `ActiveRecord`-like Models](#315-sync-array-of-nested-form-objects-to-activerecord-like-models)
   16. [Customize Sync to Array of Models](#316-customize-sync-to-array-of-models)
   17. [Model Validation and Persistence](#317-model-validation-and-persistence)
   18. [Copy Model Validation Errors into Form Object](#318-copy-model-validation-errors-into-form-object)   
   19. [Serialize Form Object to Model Hash](#319-serialize-form-object-to-model-hash)
4. [Rails Example](#4-rails-example)
5. [Reference Guide: `attribute`'s paremeters](#5-reference-guide-attributes-parameters)
   1. [`FormObj::Struct`](#51-formobjstruct)
      1. [Parameter `array`](#511-parameter-array)
      2. [Parameter `class`](#512-parameter-class)
      3. [Parameter `default`](#513-parameter-default)
      4. [Parameter `primary_key`](#514-parameter-primary_key)
   2. [`FormObj::Form`](#52-formobjform)
   3. [`FormObj::Form` with included `FormObj::ModelMapper`](#53-formobjform-with-included-formobjmodelmapper)
      1. [Parameter `model`](#531-parameter-model)
      2. [Parameter `model_attribute`](#532-parameter-model_attribute)
      3. [Parameter `model_class`](#533-parameter-model_class)
      4. [Parameter `model_hash`](#534-parameter-model_hash)
      5. [Parameter `model_nesting`](#535-parameter-model_nesting)
      6. [Parameter `read_from_model`](#536-parameter-read_from_model)
      7. [Parameter `write_to_model`](#537-parameter-write_to_model)

### 1. `FormObj::Struct`

Inherit your class from `FormObj::Struct` and define its attributes.

```ruby
class Team < FormObj::Struct
  attribute :name
  attribute :year
end
```

Read and write attribute values using dot-notation.

```ruby
team = Team.new             # => #<Team name: nil, year: nil> 
team.name = 'Ferrari'       # => "Ferrari"
team.year = 1950            # => 1950

team.name                   # => "Ferrari"
team.year                   # => 1950
```

Initialize attributes in constructor.

```ruby
team = Team.new(
    name: 'Ferrari', 
    year: 1950
)                           # => #<Team name: "Ferrari", year: 1950>  
team.name                   # => "Ferrari"
team.year                   # => 1950
```

Update attributes using `update_attributes` method.

```ruby
team.update_attributes(
    name: 'McLaren',
    year: 1966
)                           # => #<Team name: "McLaren", year: 1966>
team.name                   # => "McLaren"
team.year                   # => 1966
```

In both cases (initialization or `update_attributes`) hash is transformed to `HashWithIndifferentAccess` before applying its values
so it doesn't matter whether keys are symbols or strings.

```ruby
team.update_attributes(
    'name' => 'Ferrari', 
    'year' => 1950
)                           # => #<Team name: "Ferrari", year: 1950>
```

Attribute value stays unchanged if hash doesn't have corresponding key.

```ruby
team = Team.new(name: 'Ferrari')    # => #<Team name: "Ferrari", year: nil>
team.update_attributes(year: 1950)  # => #<Team name: "Ferrari", year: 1950>
```

Exception `UnknownAttributeError` is raised if there is key that doesn't correspond to any attribute.

```ruby
Team.new(name: 'Ferrari', a: 1)     # => FormObj::UnknownAttributeError: a
Team.new.update_attributes(a: 1)    # => FormObj::UnknownAttributeError: a
```

Use parameter `raise_if_not_found: false` in order to avoid exception and silently skip unknown key in the hash.

```ruby
team = Team.new({
    name: 'Ferrari', 
    a: 1
}, raise_if_not_found: false)    # => #<Team name: "Ferrari", year: nil> 

team.update_attributes({
    name: 'McLaren',
    a: 1
}, raise_if_not_found: false)    # => #<Team name: "McLaren", year: nil>
```

Define default attribute value using `default` parameter.
Use `Proc` to calculate default value dynamically. 
`Proc` is calculated only once at the moment of first access to attribute. 
`Proc` receives two arguments:
- `struct_class` - class (!!! not an instance) where attribute is defined
- `attribute` - internal representation of attribute 

```ruby
class Team < FormObj::Struct
  attribute :name, default: 'Ferrari'
  attribute :year, default: ->(struct_class, attribute) { struct_class.default_year(attribute) }
  
  def self.default_year(attribute)
    "#{attribute.name} = 1950"
  end
end

team = Team.new      # => #<Team name: "Ferrari", year: "year = 1950"> 
team.name            # => "Ferrari"  
team.year            # => "year = 1950" 
```

#### 1.1. Nesting `FormObj::Struct`

Use blocks to define nested structs.

```ruby
class Team < FormObj::Struct
  attribute :name
  attribute :year
  attribute :car do
    attribute :code
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end
```

Or explicitly define nested struct classes.

```ruby
class Engine < FormObj::Struct
  attribute :power
  attribute :volume
end
class Car < FormObj::Struct
  attribute :code
  attribute :driver
  attribute :engine, class: Engine
end
class Team < FormObj::Struct
  attribute :name
  attribute :year
  attribute :car, class: Car
end
```

Read and write attribute values using dot-notation.

```ruby
team = Team.new                # => #<Team name: nil, year: nil, car: #< code: nil, driver: nil, engine: #< power: nil, volume: nil>>> 
team.name = 'Ferrari'          # => "Ferrari"
team.year = 1950               # => 1950
team.car.code = '340 F1'       # => "340 F1"
team.car.driver = 'Ascari'     # => "Ascari"
team.car.engine.power = 335    # => 335
team.car.engine.volume = 4.1   # => 4.1

team.name                      # => "Ferrari"
team.year                      # => 1950
team.car.code                  # => "340 F1"
team.car.driver                # => "Ascari"
team.car.engine.power          # => 335
team.car.engine.volume         # => 4.1
```

Initialize nested struct using nested hash.

```ruby
team = Team.new(
    name: 'Ferrari',
    year: 1950,
    car: {
        code: '340 F1',
        driver: 'Ascari',
        engine: {
            power: 335,
            volume: 4.1,
        }
    }
)                        # => #<Team name: "Ferrari", year: 1950, car: #< code: "340 F1", driver: "Ascari", engine: #< power: 335, volume: 4.1>>>  

team.name                # => "Ferrari"
team.year                # => 1950
team.car.code            # => "340 F1"
team.car.driver          # => "Ascari"
team.car.engine.power    # => 335
team.car.engine.volume   # => 4.1
```

Update nested struct using nested hash.

```ruby
team.update_attributes(
    name: 'McLaren',
    year: 1966,
    car: {
      code: 'M2B',
      driver: 'Bruce McLaren',
      engine: {
        power: 300,
        volume: 3.0
      }
    }
)                           # => #<Team name: "McLaren", year: 1966, car: #< code: "M2B", driver: "Bruce McLaren", engine: #< power: 300, volume: 3.0>>>

team.name                   # => "McLaren"
team.year                   # => 1966
team.car.code               # => "M2B"
team.car.driver             # => "Bruce McLaren"
team.car.engine.power       # => 300
team.car.engine.volume      # => 3.0
```

Use hash to define default value of nested struct defined with block.

```ruby
class Team < FormObj::Struct
  attribute :car, default: { code: '340 F1', driver: 'Ascari' } do
    attribute :code
    attribute :driver
  end
end

team = Team.new      # => #<Team car: #< code: "340 F1", driver: "Ascari">>  
team.car.code        # => "340 F1"  
team.car.driver      # => "Ascari" 
```

Use hash or struct instance to define default value of nested struct defined with class. 

```ruby
class Car < FormObj::Struct
  attribute :code
  attribute :driver
end

class Team < FormObj::Struct
  attribute :car, class: Car, default: Car.new(code: '340 F1', driver: 'Ascari')
end

team = Team.new      # => #<Team car: #<Car code: "340 F1", driver: "Ascari">>  
team.car.code        # => "340 F1"  
team.car.driver      # => "Ascari" 
```

The struct instance class should correspond to nested attribute class!

```ruby
class Team < FormObj::Struct
  attribute :car, class: Car, default: 36
end

Team.new      # => FormObj::WrongDefaultValueClassError: FormObj::WrongDefaultValueClassError  
```

#### 1.2. Array of `FormObj::Struct`

Use parameter `array: true` in order to define an array of nested structs.
Define `primary_key` so that `update_attribute` method be able to distinguish 
whether to update existing array element or create a new one. 
By default attribute `id` is considered to be a primary key.

```ruby
class Team < FormObj::Struct
  attribute :name
  attribute :year
  attribute :cars, array: true do
    attribute :code, primary_key: true     # <- primary key is specified on attribute level
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end
```

or

```ruby
class Team < FormObj::Struct
  attribute :name
  attribute :year
  attribute :cars, array: true, primary_key: :code do     # <- primary key is specified on struct level
    attribute :code
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end
```

or

```ruby
class Engine < FormObj::Struct
  attribute :power
  attribute :volume
end
class Car < FormObj::Struct
  attribute :code, primary_key: true      # <- primary key is specified on attribute level
  attribute :driver
  attribute :engine, class: Engine
end
class Team < FormObj::Struct
  attribute :name
  attribute :year
  attribute :cars, array: true, class: Car
end
```

or

```ruby
class Engine < FormObj::Struct
  attribute :power
  attribute :volume
end
class Car < FormObj::Struct
  attribute :code
  attribute :driver
  attribute :engine, class: Engine
end
class Team < FormObj::Struct
  attribute :name
  attribute :year
  attribute :cars, array: true, class: Car, primary_key: :code      # <- primary key is specified on struct level 
end
```

Read and write attribute values using dot-notation.
Add new elements in the array using method `create`.

```ruby
team = Team.new               # => #<Team name: nil, year: nil, cars: []>
team.name = 'Ferrari'         # => "Ferrari"
team.year = 1950              # => 1950

team.cars.size 				  # => 0
car1 = team.cars.create       # => #< code: nil, driver: nil, engine: #< power: nil, volume: nil>> 
team.cars.size 				  # => 1
car1.code = '340 F1'          # => "340 F1"
car1.driver = 'Ascari'        # => "Ascari"
car1.engine.power = 335       # => 335
car1.engine.volume = 4.1      # => 4.1

car2 = team.cars.create       # => #< code: nil, driver: nil, engine: #< power: nil, volume: nil>>
team.cars.size 				  # => 2
car2.code = '275 F1'          # => "275 F1"        
car2.driver = 'Villoresi'     # => "Villoresi"                
car2.engine.power = 330       # => 330              
car2.engine.volume = 3.3      # => 3.3                

team.name                     # => "Ferrari"
team.year                     # => 1950

team.cars[0].code             # => "340 F1"
team.cars[0].driver           # => "Ascari"
team.cars[0].engine.power     # => 335
team.cars[0].engine.volume    # => 4.1

team.cars[1].code             # => "275 F1"
team.cars[1].driver           # => "Villoresi"
team.cars[1].engine.power     # => 330
team.cars[1].engine.volume    # => 3.3
```

Initialize attributes using hash with array of hashes.

```ruby
team = Team.new(
    name: 'Ferrari',
    year: 1950,
    cars: [
      {
          code: '340 F1',
          driver: 'Ascari',
          engine: {
              power: 335,
              volume: 4.1,
          }
      }, {
          code: '275 F1',
          driver: 'Villoresi',
          engine: {
              power: 330,
              volume: 3.3,
          }
      }
    ],
)                             # => #<Team name: "Ferrari", year: 1950, cars: [#< code: "340 F1", driver: "Ascari", engine: #< power: 335, volume: 4.1>>, #< code: "275 F1", driver: "Villoresi", engine: #< power: 330, volume: 3.3>>]>
                            
team.name                     # => "Ferrari"
team.year                     # => 1950

team.cars[0].code             # => "340 F1"
team.cars[0].driver           # => "Ascari"
team.cars[0].engine.power     # => 335
team.cars[0].engine.volume    # => 4.1

team.cars[1].code             # => "275 F1"
team.cars[1].driver           # => "Villoresi"
team.cars[1].engine.power     # => 330
team.cars[1].engine.volume    # => 3.3
```

Update attributes using hash with array of hashes.

```ruby
team.update_attributes(
    name: 'McLaren',
    year: 1966,
    cars: [
      {
          code: '275 F1',
          driver: 'Bruce McLaren',
          engine: {
              volume: 3.0
          }
      }, {
          code: 'M7A',
          driver: 'Denis Hulme',
          engine: {
              power: 415,
          }
      }
    ],
)                               # => #<Team name: "McLaren", year: 1966, cars: [#< code: "M2B", driver: "Bruce McLaren", engine: #< power: nil, volume: 3.0>>, #< code: "M7A", driver: "Denis Hulme", engine: #< power: 415, volume: nil>>]>
                            
team.name                       # => "McLaren"
team.year                       # => 1966

team.cars[0].code               # => "275 F1"
team.cars[0].driver             # => "Bruce McLaren"
team.cars[0].engine.power       # => 330    - this value was not updated in :update_attributes method
team.cars[0].engine.volume      # => 3.0

team.cars[1].code               # => "M7A"
team.cars[1].driver             # => "Denis Hulme"
team.cars[1].engine.power       # => 415
team.cars[1].engine.volume      # => nil    - this value is nil because this car was created in :updated_attributes method
```

Use `primary_key` method on class to get primary key attribute name.
Use `primary_key` and `primary_key=` method on instance to get and set primary key attribute value.

```ruby
Team.primary_key                # => :id  - By default primary key is :id even if there is no such attribute
Car.primary_key                 # => :code 
team.cars.first.primary_key     # => "275 F1"
team.cars.last.primary_key      # => "M7A"
```

`update_attributes` compares present elements in the array with new elements in hash by using primary key.
By default `update_attributes`:
- calls attribute setter under hood to update attribute value of present elements,
- calls `FormObj::Struct` constructor to create all new elements (that exists in the hash but absent in the present array),
- calls `delete_if` to delete all removed elements (that exists in the present array but absent in the hash).

Default behaviour could be easily redefined by overwriting corresponding methods.

```ruby
class MyStruct < FormObj::Struct
  class Array < FormObj::Struct::Array
    private

    def create_item(hash, raise_if_not_found:)
      puts "Create new element from #{hash}"
      super
    end

    def delete_items(ids)
      each do |item|
        if ids.include? item.primary_key
          item._destroy = true
          puts "Mark item #{item.primary_key} for deletion"
        end
      end
    end
  end

  def self.array_class
    MyStruct::Array
  end

  def self.nested_class
    MyStruct
  end

  private

  def update_attribute(attribute, new_value)
    puts "Update attribute :#{attribute.name} value from #{send(attribute.name)} to #{new_value}"
    super
  end
end

class Team < MyStruct
  attribute :name
  attribute :year
  attribute :cars, array: true, primary_key: :code do
    attribute :code
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
    attr_accessor :_destroy
  end
end

team = Team.new(name: 'Ferrari', cars: [{ code: '340 F1' }, { code: '275 F1' }])
# => Update attribute :name value from  to Ferrari
# => Create new element from {"code"=>"340 F1"}
# => Update attribute :code value from  to 340 F1
# => Create new element from {"code"=>"275 F1"}
# => Update attribute :code value from  to 275 F1
# => => #<Team name: "Ferrari", year: nil, cars: [#< code: "340 F1", driver: nil, engine: #< power: nil, volume: nil>>, #< code: "275 F1", driver: nil, engine: #< power: nil, volume: nil>>]> 

team.update_attributes(cars: [{ code: '275 F1' }])
# => Update attribute :code value from 275 F1 to 275 F1
# => Mark item 340 F1 for deletion
# => => #<Team name: "Ferrari", year: nil, cars: [#< code: "340 F1", driver: nil, engine: #< power: nil, volume: nil>>, #< code: "275 F1", driver: nil, engine: #< power: nil, volume: nil>>]> 
``` 

Use array of hashes to define default array of nested structs defined with block.

```ruby
class Team < FormObj::Struct
  attribute :cars, array: true, default: [{ code: '340 F1', driver: 'Ascari' }, { code: '275 F1', driver: 'Villoresi' }] do
    attribute :code
    attribute :driver
  end
end

team = Team.new         # => #<Team cars: [#< code: "340 F1", driver: "Ascari">, #< code: "275 F1", driver: "Villoresi">]>   
team.cars.size          # => 2  
team.cars[0].code       # => "340 F1"  
team.cars[0].driver     # => "Ascari"  
team.cars[1].code       # => "275 F1"  
team.cars[1].driver     # => "Villoresi"  
```

Use array of hashes or struct instances to define default array of nested structs defined with class.

```ruby
class Car < FormObj::Struct
  attribute :code
  attribute :driver
end

class Team < FormObj::Struct
  attribute :cars, class: Car, array: true, default: [Car.new(code: '340 F1', driver: 'Ascari'), { code: '275 F1', driver: 'Villoresi' }]
end

team = Team.new         # => #<Team cars: [#<Car code: "340 F1", driver: "Ascari">, #<Car code: "275 F1", driver: "Villoresi">]>    
team.cars.size          # => 2  
team.cars[0].code       # => "340 F1"  
team.cars[0].driver     # => "Ascari"  
team.cars[1].code       # => "275 F1"  
team.cars[1].driver     # => "Villoresi"  
```

The struct instance class should correspond to nested attribute class!

```ruby
class Team < FormObj::Struct
  attribute :cars, class: Car, array: true, default: [36]
end

Team.new      # => FormObj::WrongDefaultValueClassError: FormObj::WrongDefaultValueClassError  
```

#### 1.3. Serialize `FormObj::Struct` to Hash

Call `to_hash()` method in order to get a hash representation of `FormObj::Struct`

```ruby
class Team < FormObj::Struct
  attribute :name
  attribute :year
  attribute :cars, array: true do
    attribute :code, primary_key: true
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end

team = Team.new(
    name: 'Ferrari',
    year: 1950,
    cars: [
      {
          code: '340 F1',
          driver: 'Ascari',
          engine: {
              power: 335,
              volume: 4.1,
          }
      }, {
          code: '275 F1',
          driver: 'Villoresi',
          engine: {
              power: 330,
              volume: 3.3,
          }
      }
    ],
)                 # => #<Team name: "Ferrari", year: 1950, cars: [#< code: "340 F1", driver: "Ascari", engine: #< power: 335, volume: 4.1>>, #< code: "275 F1", driver: "Villoresi", engine: #< power: 330, volume: 3.3>>]>

team.to_hash      # => {
                  # =>    :name => "Ferrari",
                  # =>    :year => 1950,
                  # =>    :cars => [{
                  # =>      :code => "340 F1",
                  # =>      :driver => "Ascari",
                  # =>      :engine => {
                  # =>        :power => 335,
                  # =>        :volume => 4.1
                  # =>      }
                  # =>    }, {
                  # =>      :code => "275 F1",
                  # =>      :driver => "Villoresi",
                  # =>      :engine => {
                  # =>        :power => 330,
                  # =>        :volume => 3.3
                  # =>      }
                  # =>    }] 
                  # => }
```

### 2. `FormObj::Form`

`FormObj::Form` is inherited from `FormObj::Struct` and adds support for Rails compatible form builders and ActiveModel validations. 

#### 2.1. `FormObj::Form` Validation

```ruby
class Team < FormObj::Form
  attribute :name
  attribute :year
  
  validates :name, length: { minimum: 10 }
end

team = Team.new(name: 'Ferrari')      # => #<Team name: "Ferrari", year: nil> 
team.valid?                           # => false
team.errors.messages                  # => {:name=>["is too short (minimum is 10 characters)"]} 
```

#### 2.2. `FormObj::Form` Persistence

In order to make `FormObj::Form` compatible with form builder it has to respond to `:persisted?` message.
Initial form is not persisted. 
It can be marked as persisted by assigning `persisted = true` which marks as persisted only form itself or
by calling `mark_as_persisted` method which marks as persisted the form itself and all nested forms and arrays.

```ruby
class Team < FormObj::Form
  attribute :name
  attribute :year
  attribute :cars, array: true do
    attribute :code, primary_key: true
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end

team = Team.new(cars: [{code: 1}])

team.persisted?                         # => false
team.cars[0].persisted?                 # => false
team.cars[0].engine.persisted?          # => false

team.persisted = true

team.persisted?                         # => false  - because nested forms are not persisted
team.cars[0].persisted?                 # => false
team.cars[0].engine.persisted?          # => false

team.cars[0].engine.persisted = true

team.persisted?                         # => false  - because nested forms are not persisted
team.cars[0].persisted?                 # => false
team.cars[0].engine.persisted?          # => true

team.mark_as_persisted

team.persisted?                         # => true
team.cars[0].persisted?                 # => true
team.cars[0].engine.persisted?          # => true
```

Change of attribute value (directly or by `update_attributes` call) will change persistence status to `false`.

```ruby
team.name = 'Ferrari'
team.persisted?                         # => false

team.mark_as_persisted
team.persisted?                         # => true

team.update_attributes(name: 'McLaren')
team.persisted?                         # => false
```

#### 2.3. Non-Existent Attributes in `FormObj::Form` `update_attributes` Do Not Raise By Default

`FormObj::Form` `update_attributes` method has `raise_if_not_found` parameter default `false` value.
In order to have the same behaviour as `FormObj::Struct` `update_attributes` explicitly specify this parameter equal to `true`

```ruby
class TeamStruct < FormObj::Struct
  attribute :name
  attribute :year
end

TeamStruct.new(name: 'Ferrari', a: 1)     # => FormObj::UnknownAttributeError: a
TeamStruct.new.update_attributes(a: 1)    # => FormObj::UnknownAttributeError: a

TeamStruct.new({ name: 'Ferrari', a: 1 }, raise_if_not_found: false)    # => #<Team name: "Ferrari", year: nil> 
TeamStruct.new.update_attributes({ a: 1 }, raise_if_not_found: false)   # => #<Team name: nil, year: nil>
```

```ruby
class TeamForm < FormObj::Form
  attribute :name
  attribute :year
end

TeamForm.new(name: 'Ferrari', a: 1)     # => #<Team name: "Ferrari", year: nil>
TeamForm.new.update_attributes(a: 1)    # => #<Team name: nil, year: nil>

TeamForm.new({ name: 'Ferrari', a: 1 }, raise_if_not_found: true)    # => FormObj::UnknownAttributeError: a 
TeamForm.new.update_attributes({ a: 1 }, raise_if_not_found: true)   # => FormObj::UnknownAttributeError: a 
``` 

#### 2.4. Delete from Array of `FormObj::Form` via `update_attributes` method

`FormObj::Struct` `update_attributes` method by default deletes all array elements that are not present in the new hash.

```ruby
class Team < FormObj::Struct
  attribute :cars, array: true, primary_key: :code do
    attribute :code
    attribute :driver
  end
end

team = Team.new(cars: [{code: 1, driver: 'Ascari'}, {code: 2, driver: 'Villoresi'}])
team.update_attributes(cars: [{code: 1}])
team.cars     # => [#< code: 1, driver: "Ascari">]                                     
```

In oppose to this `FormObj::Form` `update_attributes` method ignores elements that are absent in the hash but
marks for destruction those elements that has `_destroy: true` key in the hash.
New elements with `_destroy: true` are not created at all. 

```ruby
class Team < FormObj::Form
  attribute :cars, array: true, primary_key: :code do
    attribute :code
    attribute :driver
  end
end

team = Team.new(cars: [{code: 1, driver: 'Ascari'}, {code: 2, driver: 'Villoresi'}])
team.update_attributes(cars: [{code: 2, driver: 'James Hunt'}])

team.cars[0].code                       # => 1
team.cars[0].driver                     # => 'Ascari'
team.cars[0].marked_for_destruction?    # => false

team.cars[1].code                       # => 2
team.cars[1].driver                     # => 'James Hunt'
team.cars[1].marked_for_destruction?    # => false

team.update_attributes(cars: [{code: 1, _destroy: true}, {code: 3, _destroy: true}])

team.cars.size                          # => 2

team.cars[0].code                       # => 2
team.cars[0].driver                     # => 'James Hunt'
team.cars[0].marked_for_destruction?    # => false

team.cars[1].code                       # => 1
team.cars[1].driver                     # => 'Ascari'
team.cars[1].marked_for_destruction?    # => true                                 
```

Use `mark_for_destruction` in order to forcefully mark an array element for destruction.

```ruby
team.cars[0].marked_for_destruction?    # => false
team.cars[0].mark_for_destruction      
team.cars[0].marked_for_destruction?    # => true
```

#### 2.5. Using `FormObj::Form` in Form Builder

```ruby
class Team < FormObj::Form
  attribute :name
  attribute :year
  attribute :cars, array: true, primary_key: :code do
    attribute :code
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end

@team = Team.new
```

```erb
<%= form_for(@team) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :year %>
  <%= f.text_field :year %>

  <% f.cars.each do |car| %>
    <%= f.fields_for(:cars, car, index: '') do |fc| %>
      <%= fc.label :code %>
      <%= fc.text_field :code %>

      <%= fc.label :driver %>
      <%= fc.text_field :driver %>

      <%= fc.field_for(:engine) do |fce| %>
        <%= fce.label :power %>
        <%= fce.text_field :power %>

        <%= fce.label :volume %>
        <%= fce.text_field :volume %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

### 3. `FormObj::ModelMapper`

Include `FormObj::ModelMapper` module and map form object attributes to one or more models by using `:model` and `:model_attribute` parameters.
Use dot notation to map model attribute to a nested model. Use colon to specify a "hash's attribute".

#### 3.1. `load_from_model` - Initialize Form Object from Model

Use `load_from_model(model)` method to initialize form object from the model. 
This method available both as class method and as instance method.

```ruby
class Team < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model_attribute: 'car.:engine.power'
end

car_model = { engine: Struct.new(:power).new(335) }
team_model = Struct.new(:team_name, :year, :car).new('Ferrari', 1950, car_model)

team = Team.load_from_model(team_model)
team.to_hash                    # => {
                                # =>    :name => "Ferrari"
                                # =>    :year => 1950
                                # =>    :engine_power => 335
                                # => }

team.load_from_model(team_model) 
```

So attributes are mapped as follows:

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `team.name` | `team_model.team_name` |
| `team.year` | `team_model.year` |
| `team.engine_power` | `team_model.car[:engine].power` |

#### 3.2. `load_from_models` - Initialize Form Object from Few Models

Use `load_from_models(models)` method to initialize form object from few models. 
This method available both as class method and as instance method.
`models` parameter is a hash where keys are the name of models and values are models themselves. 

By default each form object attribute is mapped to `:default` model.
Use parameter `:model` to map it to another model. 

```ruby
class Team < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model: :car, model_attribute: ':engine.power'
end

car_model = { engine: Struct.new(:power).new(335) }
team_model = Struct.new(:team_name, :year).new('Ferrari', 1950)    # <- doesn't have car attribute !!!

team = Team.load_from_models(default: team_model, car: car_model)
team.to_hash                    # => {
                                # =>    :name => "Ferrari"
                                # =>    :year => 1950
                                # =>    :engine_power => 335
                                # => }

team.load_from_models(default: team_model, car: car_model) 
```

So attributes are mapped as follows:

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `team.name` | `team_model.team_name` |
| `team.year` | `team_model.year` |
| `team.engine_power` | `car_model[:engine].power` |

#### 3.3. Do Not Map Certain Attribute

Use `model_attribute: false` in order to avoid mapping of this attribute.

```ruby
class Team < FormObj::Form
  include ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model_attribute: false
end

team_model = Struct.new(:team_name, :year, :engine_power).new('Ferrari', 1950, 335)

team = Team.load_from_model(team_model)
team.to_hash                    # => {
                                # =>    :name => "Ferrari"
                                # =>    :year => 1950
                                # =>    :engine_power => nil
                                # => }
```

So attributes are mapped as follows:

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `form.name` | `team_model.team_name` |
| `form.year` | `team_model.year` |
| `form.engine_power` | - |

It also works for other methods: `sync_to_model(s)`, `to_model(s)_hash`, `copy_errors_from_model(s)`. 

#### 3.4. Do Not Map Certain Attribute For Reading From Model

Use `read_from_model: false` in order to avoid mapping of the attribute only in `load_from_model(s)` methods.

```ruby
class Team < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name
  attribute :year, read_from_model: false
end

team_model = Struct.new(:name, :year).new('Ferrari', 1950)
team = Team.new(name: 'McLaren', year: 1966)

team.load_from_model(team_model)

team.name                       # => "Ferrari"
team.year                       # => 1966
```

#### 3.5. Do Not Map Certain Attribute For Writing to Model

Use `write_to_model: false` in order to avoid mapping of the attribute only in `sync_to_model(s)`, `to_model(s)_hash`, `copy_errors_from_model(s)` methods.

```ruby
class Team < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name
  attribute :year, write_to_model: false
end

team_model = Struct.new(:name, :year).new('Ferrari', 1950)
team = Team.new(name: 'McLaren', year: 1966)

team.sync_to_model(team_model)

team_model.name                 # => "McLaren"
team_model.year                 # => 1950

team.to_model_hash              # => {:name => "McLaren"}
```

#### 3.6. Map Nested Form Objects

Nested forms are mapped by default to corresponding nested models.

```ruby
class Team < FormObj::Form
  include ModelMapper
    
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :car do
    attribute :code
    attribute :driver
  end
end

car_model = Struct.new(:code, :driver).new('340 F1', 'Ascari')
team_model = Struct.new(:team_name, :year, :car).new('Ferrari', 1950, car_model)

team = Team.load_from_model(team_model)
team.to_hash                    # => {
                                # =>    :name => "Ferrari",
                                # =>    :year => 1950,
                                # =>    :car => {
                                # =>        :code => "340 F1",
                                # =>        :driver => "Ascari"   
                                # =>    }
                                # => }
```

So attributes are mapped as follows:

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `team.name` | `team_model.team_name` |
| `team.year` | `team_model.year` |
| `team.car.code` | `team_model.car.code` |
| `team.car.driver` | `team_model.car.driver` |

It also works for other methods: `sync_to_model(s)` and `to_model(s)_hash` 

#### 3.7. Map Nested Form Object to Parent Level Model

Use `model_nesting: false` parameter to map nested form object to parent level model.

```ruby
class NestedForm < FormObj::Form
  include ModelMapper
    
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :car, model_nesting: false do   # nesting only in form object but not in a model
    attribute :code
    attribute :driver
  end
end

team_model = Struct.new(:team_name, :year, :code, :driver).new('Ferrari', 1950, '340 F1', 'Ascari')

team = Team.load_from_model(team_model)
team.to_hash                    # => {
                                # =>    :name => "Ferrari",
                                # =>    :year => 1950,
                                # =>    :car => {
                                # =>        :code => "340 F1",
                                # =>        :driver => "Ascari"   
                                # =>    }
                                # => }
```

So attributes are mapped as follows:

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `team.name` | `team_model.team_name` |
| `team.year` | `team_model.year` |
| `team.car.code` | `team_model.code` |
| `team.car.driver` | `team_model.driver` |

It also works for other methods: `sync_to_model(s)` and `to_model(s)_hash` 

#### 3.8. Map Nested Form Object to A Hash Model

Use `model_hash: true` in order to map a nested form object to a hash as a model.

```ruby
class Team < FormObj::Form
  include ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :car, model_hash: true do   # nesting only in form object but not in a model
    attribute :code
    attribute :driver
  end
end

car_model = { code: '340 F1', driver: 'Ascari' }
team_model = Struct.new(:team_name, :year, :car).new('Ferrari', 1950, car_model)

team = Team.load_from_model(team_model)
team.to_hash                    # => {
                                # =>    :name => "Ferrari",
                                # =>    :year => 1950,
                                # =>    :car => {
                                # =>        :code => "340 F1",
                                # =>        :driver => "Ascari"   
                                # =>    }
                                # => }
```

So attributes are mapped as follows:

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `team.name` | `team_model.team_name` |
| `team.year` | `team_model.year` |
| `team.car.code` | `team_model.car[:code]` |
| `team.car.driver` | `team_model.car[:driver]` |

It also works for other methods: `sync_to_model(s)` and `to_model(s)_hash` 

#### 3.9. Map Array of Nested Form Objects

Array of nested forms is mapped by default to corresponding array (or for example to `ActiveRecord::Relation` in case of Rails) of nested models.

```ruby
class Team < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name
  attribute :year
  attribute :cars, array: true, model_class: CarModel do
    attribute :code, primary_key: true
    attribute :driver
  end
end
``` 

#### 3.10. Map Array of Nested Form Objects to Nested Array of Nested Models

If corresponding `:model_attribute` parameter uses dot notations to reference
nested models the value of `:model_class` parameter should be an array of corresponding model classes.

```ruby
class ArrayForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name
  attribute :year
  attribute :cars, array: true, model_attribute: 'equipment.cars', model_class: [Equipment, CarModel] do
    attribute :code, primary_key: true
    attribute :driver
  end
end
``` 

#### 3.11. Default Implementation of Loading of Array of Models 

By default `load_from_model(s)` methods loads all models from arrays.

```ruby
class Team < FormObj::Form
  include ModelMapper
    
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :cars, array: true do
    attribute :code
    attribute :driver
  end
  attribute :colours, array: true do
    attribute :name
    attribute :rgb
  end
end

CarModel = Struct.new(:code, :driver)
ColourModel = Struct.new(:name, :rgb)

cars_model = [CarModel.new('340 F1', 'Ascari'), CarModel.new('275 F1', 'Villoresi')]
colours_model = [ColourModel.new(:red, 0xFF0000), ColourModel.new(:white, 0xFFFFFF)]
team_model = Struct.new(:team_name, :year, :cars, :colours).new('Ferrari', 1950, cars_model, colours_model)

team = Team.load_from_model(team_model)
team.to_hash                    # => {
                                # =>    :name => "Ferrari",
                                # =>    :year => 1950,
                                # =>    :cars => [{
                                # =>        :code => "340 F1",
                                # =>        :driver => "Ascari"   
                                # =>    }, {
                                # =>        :code => "275 F1",
                                # =>        :driver => "Villoresi"   
                                # =>    }],
                                # =>    :colours => [{
                                # =>        :name => :red,
                                # =>        :rgb => 0xFF0000   
                                # =>    }, {
                                # =>        :name => :white,
                                # =>        :rgb => 0xFFFFFF   
                                # =>    }]
                                # => }
```

#### 3.12. Custom Implementation of Loading of Array of Models  

`FormObj::ModelMapper::Array` class implements method (where `*args` are additional params passed to `load_from_model(s)` methods)

```ruby
  def iterate_through_models_to_load_them(models, *args, &block)
    models.each { |model| block.call(model) }
  end
```

This method should iterate through all models that has to be loaded and call a block for each of them.
In the example above it will receive `cars_model` as the value of `models` parameter. 
Overwrite this method in order to implement your own logic.

```ruby
class ArrayLoadLimit < FormObj::ModelMapper::Array
  private
  
  def iterate_through_models_to_load_them(models, params = {}, &block)
    models = models.slice(params[:offset] || 0, params[:limit] || 999999999) if model_attribute.names.last == :cars
    super(models, &block)
  end
end

class LoadLimitForm < FormObj::Form
  include FormObj::ModelMapper

  def self.array_class
    ArrayLoadLimit
  end
end

class Team < LoadLimitForm
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :cars, array: true do
    attribute :code
    attribute :driver
  end
  attribute :colours, array: true do
    attribute :name
    attribute :rgb
  end
end

CarModel = Struct.new(:code, :driver)
ColourModel = Struct.new(:name, :rgb)

cars_model = [CarModel.new('340 F1', 'Ascari'), CarModel.new('275 F1', 'Villoresi')]
colours_model = [ColourModel.new(:red, 0xFF0000), ColourModel.new(:white, 0xFFFFFF)]
team_model = Struct.new(:team_name, :year, :cars, :colours).new('Ferrari', 1950, cars_model, colours_model)

team = Team.load_from_model(team_model, offset: 0, limit: 1)
team.to_hash                    # => {
                                # =>    :name => "Ferrari",
                                # =>    :year => 1950,
                                # =>    :cars => [{
                                # =>        :code => "340 F1",
                                # =>        :driver => "Ascari"   
                                # =>    }],
                                # =>    :colours => [{
                                # =>        :name => :red,
                                # =>        :rgb => 0xFF0000   
                                # =>    }, {
                                # =>        :name => :white,
                                # =>        :rgb => 0xFFFFFF   
                                # =>    }] 
                                # => }

team = Team.load_from_model(team_model, offset: 1, limit: 1)
team.to_hash                    # => {
                                # =>    :name => "Ferrari",
                                # =>    :year => 1950,
                                # =>    :cars => [{
                                # =>        :code => "275 F1",
                                # =>        :driver => "Villoresi"   
                                # =>    }],
                                # =>    :colours => [{
                                # =>        :name => :red,
                                # =>        :rgb => 0xFF0000   
                                # =>    }, {
                                # =>        :name => :white,
                                # =>        :rgb => 0xFFFFFF   
                                # =>    }]
                                # => }
```

Note that our new implementation of `iterate_through_models_to_load_them` limits only cars but not colours.
It identifies requested model attribute using `model_attribute.names` which returns 
an array of model attribute accessors (in our example `[:cars]`)
 
In case of `ActiveRecord` model `iterate_through_models_to_load_them` will receive an instance of `ActiveRecord::Relation` as `models` parameter.
This allows to load in the memory only necessary associated models.

```ruby
class ArrayLoadLimit < FormObj::ModelMapper::Array
  private
  
  def iterate_through_models_to_load_them(models, params = {}, &block)
    models = models.offset(params[:offset] || 0).limit(params[:limit] || 999999999) if model_attribute.names.last == :cars
    super(models, &block)
  end
end
```
     
#### 3.13. Sync Form Object to Model(s)

Use `sync_to_models(models)` to sync form object attributes to mapped models.
Method returns self so calls could be chained.

```ruby
class Team < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model: :car, model_attribute: ':engine.power'
end

default_model = Struct.new(:team_name, :year).new('Ferrari', 1950)
car_model = { engine: Struct.new(:power).new(335) }

team = Team.new
team.update_attributes(name: 'McLaren', year: 1966, engine_power: 415)
team.sync_to_models(default: default_model, car: car_model)

default_model.team_name         # => "McLaren"
default_model.year              # => 1966
car_model[:engine].power        # => 415 
``` 

Use `sync_to_model(model)` if form object is mapped to single model.

#### 3.14. Sync Array of Nested Form Objects to Model(s)

By default `FormObj::Form` with included `FormObj::ModelMapper` will try to match Form Objects and Models by primary key.
Therefore Form Object primary key attribute has to be mapped to top level Model attribute.

```ruby
TeamModel = Struct.new(:cars)
CarModel = Struct.new(:code, :driver)

class Team < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :cars, array: true, model_class: CarModel do
    attribute :code, primary_key: true
    attribute :driver
  end
end
```

Attributes of successfully matched models will be updated from corresponding form objects. 

```ruby
team_model = TeamModel.new([CarModel.new('275 F1', 'Ascari')])
team = Team.new(cars: [{ code: '275 F1', driver: 'Villoresi' }])

team_model.cars                     # => [#<struct CarModel code="275 F1", driver="Ascari">]
team.sync_to_model(team_model)  
team_model.cars                     # => [#<struct CarModel code="275 F1", driver="Villoresi">]
```

New models will be created for form object that doesn't have corresponding models. 
In order to create a new model the model class has to be known.
It can be specified by `:model_class` parameter. 
Otherwise form object will try to guess it from the attribute name.

```ruby
team_model = TeamModel.new([])
team = Team.new(cars: [{ code: '275 F1', driver: 'Villoresi' }])

team_model.cars                     # => []
team.sync_to_model(team_model)  
team_model.cars                     # => [#<struct CarModel code="275 F1", driver="Villoresi">]
```

Models that does not have corresponding objects will stay without changes.

```ruby
team_model = TeamModel.new([CarModel.new('275 F1', 'Ascari')])
team = Team.new(cars: [{ code: '275 F1', driver: 'Villoresi' }, { code: '340 F1', driver: 'Hunt' }])

team_model.cars                     # => [#<struct CarModel code="275 F1", driver="Ascari">]
team.sync_to_model(team_model)  
team_model.cars                     # => [#<struct CarModel code="275 F1", driver="Villoresi">, #<struct CarModel code="340 F1", driver="Hunt">]
```

If array does not respond to `:where` models that correspond to form objects marked for destruction will be destroyed.

```ruby
team_model = TeamModel.new([CarModel.new('275 F1', 'Ascari')])
team = Team.load_from_model(team_model)                           # => #<Team cars: [#< code: "275 F1", driver: nil>]>
team.update_attributes(cars: [{ code: '275 F1', _destroy: true }])    # => #<Team cars: [#< code: "275 F1", driver: nil marked_for_destruction>]>

team_model.cars                                                       # => [#<struct CarModel code="275 F1", driver="Ascari">]
team.sync_to_model(team_model)  
team_model.cars                                                       # => []
```

#### 3.15. Sync Array of Nested Form Objects to `ActiveRecord`-like Models

if array respond to `:where` (aka `ActiveRecord`) models that correspond to form objects marked for destruction will be also marked for destruction.

```ruby
class TeamModel < ApplicationRecord
  has_many :cars
end

class Team < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :cars, array: true, model_class: CarModel do
    attribute :id
    attribute :code
    attribute :driver
  end
end

team_model = TeamModel.find(1)
team_model.cars                                   # => #<ActiveRecord::Associations::CollectionProxy [#<Car id: 1, code: "275 F1", driver: "Ascari">]>
team_model.cars.first.marked_for_destruction?     # => false

team = Team.load_from_model(team_model).update_attributes(cars: [{ id: 1, _destroy: true }])
team.sync_to_model(team_model)

team_model.cars                                   # => #<ActiveRecord::Associations::CollectionProxy [#<Car id: 1, code: "275 F1", driver: "Ascari">]>
team_model.cars.first.marked_for_destruction?     # => true
```

#### 3.16. Customize Sync to Array of Models

`FormObj::ModelMapper::Array` has private methods: `sync_creation_to_models`, `sync_update_to_models`, `sync_destruction_to_models`.
They are called during syncing process and could be overwritten. 
The new descendant of `FormObj::ModelMapper::Array` class has to be returned from `array_class` class method.
As well as the `FormObj::Form` descendant class itself has to be returned from `nested_class` class method.

```ruby
  class MyForm < FormObj::Form
    class Array < FormObj::ModelMapper::Array
      private

      def sync_destruction_to_models(models, ids_to_destroy)
        if models[:default].respond_to? :where
          models[:default].where(model_primary_key.name => ids_to_destroy).each { |model| puts "Mark for deletion model #{model}" }
        else
          models[:default].select { |model| ids_to_destroy.include? model_primary_key.read_from_model(model) }.each { |model| puts "Delete model #{model}" }
        end
        super
      end

      def sync_update_to_models(models, items_to_update)
        items_to_update.each_pair do |model, form_object|
          puts "Update model #{model} with #{form_object.to_model_hash}"
        end
        super
      end

      def sync_creation_to_models(models, form_objects_to_create)
        form_objects_to_create.each do |form_object|
          puts "Create model from #{form_object.to_model_hash}"
        end
        super
      end
    end

    include FormObj::ModelMapper

    def self.array_class
      Array
    end

    def self.nested_class
      MyForm
    end
  end
```

#### 3.17. Model Validation and Persistence

`sync_to_model(s)` do not call `save` method on the model(s).
Also they don't call `valid?` method on the model(s). 
Instead they just assign form object attributes value to mapped model attributes
using `<attribute_name>=` accessors on the model(s).

It is completely up to developer to do any additional validations on the model(s) and save it(them).

#### 3.18. Copy Model Validation Errors into Form Object

Even though validation could and should happen in the form object it is possible to have (additional) validation(s) in the model(s).
In this case it is handy to copy model validation errors to form object in order to be able to present them to the user in a standard way.

Use `copy_errors_from_models(models)` or `copy_errors_from_model(model)` in order to do it.
Methods return self so one can chain calls.

```ruby
team.copy_errors_from_models(default: default_model, car: car_model)
``` 

In case of single model:
```ruby
team.copy_errors_from_model(model)
```

For the moment `copy_errors_from_model(s)` do not support nested form object/model and array of nested form objects/models. 

#### 3.19. Serialize Form Object to Model Hash

Use `to_model_hash(model = :default)` to get hash representation of the model that mapped to the form object.

```ruby
class Team < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model: :car, model_attribute: ':engine.power'
end

team = Team.new(name: 'McLaren', year: 1966, engine_power: 415)

team.to_model_hash              # => { :team_name => "McLaren", :year => 1966 }
team.to_model_hash(:default)    # => { :team_name => "McLaren", :year => 1966 }
team.to_model_hash(:car)        # => { :engine => { :power => 415 } }
``` 

Use `to_models_hash()` to get hash representation of all models that mapped to the form object.

```ruby
team.to_models_hash             # => {
                                # =>   default: { :team_name => "McLaren", :year => 1966 }
                                # =>   car: { :engine => { :power => 415 } }
                                # => } 
``` 

If array of form objects mapped to the parent model (`model_nesting: false`) it is serialized to `:self` key.

```ruby
class Team < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name
  attribute :year
  attribute :cars, array: true, model_nesting: false do
    attribute :code, primary_key: true
    attribute :driver
  end
end

team = Team.new(
    name: 'McLaren', 
    year: 1966, 
    cars: [{
      code: 'M2B', 
      driver: 'Bruce McLaren'
    }, {
      code: 'M7A',
      driver: 'Denis Hulme'
    }]
)

team.to_model_hash    # => { 
                      # =>    :team_name => "McLaren", 
                      # =>    :year => 1966,
                      # =>    :self => {
                      # =>      :code => "M2B",
                      # =>      :driver => "Bruce McLaren"
                      # =>    }, {    
                      # =>      :code => "M7A",
                      # =>      :driver => "Denis Hulme"
                      # =>    }  
                      # => }
```

### 4. Rails Example

```ruby
# db/migrate/yyyymmddhhmiss_create_team.rb
class CreateTeam < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :team_name
      t.integer :year
    end
  end
end
```
```ruby
# app/models/team.rb
class Team < ApplicationRecord
  has_many :cars, autosave: true
  
  validates :year, numericality: { greater_than_or_equal_to: 1950 }
end
```
```ruby
# db/migrate/yyyymmddhhmiss_create_car.rb
class CreateCar < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.references :team    
      t.string :code
      t.text :engine
    end
  end
end
```
```ruby
# app/models/car.rb
class Car < ApplicationRecord
  belongs_to :team
  
  serialize :engine, Hash
end
```
```ruby
# app/form_objects/team_form.rb
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :id
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :cars, array: true do
    attribute :id
    attribute :code
    attribute :engine_power, model_attribute: 'engine.:power'
    
    validates :code, presence: true
  end
  
  validates :name, :year, presence: true
end
```
```ruby
# app/controllers/teams_controller.rb
class TeamsController < ApplicationController
  def show
    @team = TeamForm.new.load_from_model(Team.find(params[:id])) 
  end
  
  def new
    @team = TeamForm.new
  end
  
  def edit
    @team = TeamForm.new.load_from_model(Team.find(params[:id]))
  end
  
  def create
    @team = TeamForm.new.update_attributes(params[:team])
    
    if @team.valid?
      @team.sync_to_model(model = Team.new) 
      if model.save
        return redirect_to team_path(model), notice: 'Team has been created'
      else
        @team.copy_errors_from_model(model) 
      end
    end
    
    render :new
  end
  
  def update
    @team = TeamForm.new.load_from_model(model = Team.find(params[:id]))
    @team.update_attributes(params[:team])
    
    if @team.valid?
      @team.sync_to_model(model)
      if model.save
        return redirect_to team_path(model), notice: 'Team has been updated'
      else
        @team.copy_errors_from_model(model)
      end
    end
    
    render :edit
  end
end
```
```erb
# app/views/teams/show.erb.erb
<p>Name: <%= @team.name %></p> 
<p>Year: <%= @team.year %></p>
<p>Cars:</p>
<ul>
  <% @team.cars.each do |car| %>
    <li><%= car.code %> (<%= car.engine[:power] %> hp)</li>    
  <% end %>
</ul>
```
```erb
# app/views/teams/new.erb.erb
<%= nested_form_for @team do |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :year %>

  <%= f.link_to_add 'Add a Car', :cars %>
<% end %>
```
```erb
# app/views/teams/edit.erb.erb
<%= nested_form_for @team do |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :year %>
  
  <%= f.fields_for :cars do |cf| %>
    <%= cf.text_field :code %>
    <%= cf.link_to_remove 'Remove the Car' %> 
  <% end %>
  <%= f.link_to_add 'Add a Car', :cars %>
<% end %>
```

### 5. Reference Guide: `attribute`'s parameters

#### 5.1 `FormObj::Struct`

##### 5.1.1. Parameter `array`

*Default value:* `false` 

Specifies attribute as an array of nested `FormObj::Struct`. 
The attribute shuld have either a block which describes the structure of array item 
or `class` parameter which refers to another `FormObj::Struct` which describes the structure of array item.

```ruby
class Team < FormObj::Struct
  attribute :cars, array: true do
    attribute :id
    attribute :driver
  end
end
```

##### 5.1.2. Parameter `class`

Specifies the class of nested `FormObj::Struct`. Cannot be used if there is block definition of nested structure.
Could be either class constant itself or the name of the class.

```ruby
class Car < FormObj::Struct
    attribute :id
    attribute :driver
end
class Team < FormObj::Struct
  attribute :cars, array: true, class: Car
end
```

##### 5.1.3. Parameter `default`

Specifies the default value of an attribute. 
For nested `FormObj::Struct` could be specified either by its instance or by its hash representation.

```ruby
class Team < FormObj::Struct
  attribute :name, default: 'Ferrari'
  attribute :cars, array: true, default: [{ id: 1, driver: 'Ascari' }] do
    attribute :id
    attribute :driver
  end
end
```

or 

```ruby
class Car < FormObj::Struct
  attribute :id
  attribute :driver
end
class Team < FormObj::Struct
  attribute :name, default: 'Ferrari'
  attribute :cars, array: true, class: 'Car', default: [Car.new(id: 1, driver: 'Ascari')]
end
```

##### 5.1.4. Parameter `primary_key`

*Default value:* `:id`

Specifies the primary key of nested `FormObj::Struct` for the array attribute. 
Could be specified either on the primary key attribute itself (`primary_key: true`)

```ruby
class Team < FormObj::Struct
  attribute :cars, array: true do
    attribute :code, primary_key: true
    attribute :driver
  end
end
```

or on the array attribute. 
In latter case the value of the parameter should the name of the primary key attribute (e.g. `primary_key: :team_name`).

```ruby
class Team < FormObj::Struct
  attribute :cars, array: true, primary_key: :code do
    attribute :code
    attribute :driver
  end
end
```
 
If both ways are mixed, than parameter specified on the array attribute will take precedence.

Composite primary key is not supported.

#### 5.2. `FormObj::Form`

All `FormObj::Struct` parameters can be used with `FormObj::Form`

#### 5.3. `FormObj::Form` with included `FormObj::ModelMapper`

All `FormObj::Form` parameters can be together with following.

##### 5.3.1. Parameter `model`

*Default value:* `:default`

Specifies the name of the model which this attribute is mapped on to. 
By default each attribute is mapped on to the `:default` model.

```ruby
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name
  attribute :engine, model: :car 
end

Car = Struct.new(:engine)
Team = Struct.new(:name) 

team = Team.new('McLaren')
car = Car.new('Ford')

team.name                                     # => "McLaren"
car.engine                                    # => "Ford"
team_form = TeamForm.load_from_models(default: team, car: car)
team_form.name                                # => "McLaren"
team_form.engine                              # => "Ford"
```

##### 5.3.2. Parameter `model_attribute`

*Default value:* `<attribute name>`

Specifies the name of the model attribute which this attribute is mapped on.
It supports dot-notation for mapping on the nested model attribute.

```ruby
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :car_power, model_attribute: 'car.engine_power' 
end

Car = Struct.new(:engine_power)
Team = Struct.new(:car) 

team = Team.new(Car.new(350))
team.car.engine_power                         # => 350
team_form = TeamForm.load_from_model(team)
team_form.car_power                           # => 350
```

Colon has to be used in front of corresponding `model_attribute` element if the nested model is a hash.

```ruby
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :car_power, model_attribute: 'car.:engine_power' 
end

Team = Struct.new(:car) 

team = Team.new(engine_power: 350)
team.car[:engine_power]                       # => 350
team_form = TeamForm.load_from_model(team)
team_form.car_power                           # => 350
```

##### 5.3.3. Parameter `model_class`

*Default value:* `<attribute name>.to_s.classify`

This parameter can be used only for nested form objects.
Specifies the class of the model which the nested form object is mapped on.
  
```ruby
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name
  attribute :engine, model: :car 
end

Car = Struct.new(:engine)
Team = Struct.new(:name) 

team = Team.new('McLaren')
car = Car.new('Ford')
team.name                                     # => "McLaren"
car.engine                                    # => "Ford"
team_form = TeamForm.load_from_models(default: team, car: car)
team_form.name                                # => "McLaren"
team_form.engine                              # => "Ford"
```

##### 5.3.4. Parameter `model_hash`

*Default value:* `false`

If nested model is hash it could be specified by means of this parameter.

```ruby
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :car, model_hash: true do
    attribute :power
  end   
end

Team = Struct.new(:car) 

team = Team.new(power: 350)
team.car[:power]                              # => 350
team_form = TeamForm.load_from_model(team)
team_form.car.power                           # => 350
```

The same result could be achieved by using `:`-notation in `model_attribute` parameter.

```ruby
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :car do
    attribute :power, model_attribute: ':power'
  end 
end

Team = Struct.new(:car) 

team = Team.new(power: 350)
team.car[:power]                              # => 350
team_form = TeamForm.load_from_model(team)
team_form.car.power                           # => 350
```

##### 5.3.5. Parameter `model_nesting`

*Default value:* `true`

This parameter can be used only for nested form objects.
By default nested form object is mapped to nested model. 
If this parameter has value `false` the nested form object will be mapped to the same model as the parent form object is.

```ruby
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :car, model_nesting: false do
    attribute :power
  end   
end

Team = Struct.new(:power) 

team = Team.new(350)
team.power                                    # => 350
team_form = TeamForm.load_from_model(team)
team_form.car.power                           # => 350
```

Compare with example where `model_nesting: true`.

```ruby
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :car, model_nesting: true do
    attribute :power
  end   
end

Car = Struct.new(:power)
Team = Struct.new(:car) 

team = Team.new(Car.new(350))
team.car.power                                # => 350
team_form = TeamForm.load_from_model(team)
team_form.car.power                           # => 350
```

`model_nesting: true` can be omitted since it is its default value.

##### 5.3.6. Parameter `read_from_model`

*Default value:* `true`

`false` value of this parameter prevents from reading attribute value from the model in
`load_from_model(s)` methods.

```ruby
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name
  attribute :year, read_from_model: false
end

Team = Struct.new(:name, :year)

team = Team.new('Ferrari', 1950)
team_form = TeamForm.new(name: 'McLaren', year: 1966)

team_form.load_from_model(team)
team_form.name                                # => "Ferrari"
team_form.year                                # => 1966 
```

##### 5.3.7. Parameter `write_to_model`

*Default value:* `true`

`false` value of this parameter 
- will prevent from writing attribute value to the model in `sync_to_model(s)` methods, 
- attribute will not be present in the hash generated by `to_model(s)_hash` methods, 
- attribute errors will not be copied from the model by `copy_errors_from_model(s)` methods.

```ruby
class TeamForm < FormObj::Form
  include FormObj::ModelMapper
  
  attribute :name
  attribute :year, write_to_model: false
end

Team = Struct.new(:name, :year)

team = Team.new('Ferrari', 1950)
team_form = TeamForm.new(name: 'McLaren', year: 1966)

team_form.sync_to_model(team)
team.name                                     # => "McLaren"
team.year                                     # => 1950

team_form.to_model_hash                       # => {:name=>"McLaren"} 
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akoltun/form_obj.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
