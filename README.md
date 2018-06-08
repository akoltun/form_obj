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

**WARNING!!!** The gem is still under development. Expect braking changes.<br/>

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
4. [Map Form Object to Models](4-map-form-objects-to-models)
   1. [Multiple Models Example](41-multiple-models-example)
   2. [Skip Attribute Mapping](42-skip-attribute-mapping)
   3. [Map Nested Form Object Attribute to Parent Level Model Attribute](43-map-nested-form-object-attribute-to-parent-level-model-attribute)
   4. [Map Nested Form Object to A Hash Model](44-map-nested-form-object-to-a-hash-model)
5. [Load Form Object from Models](5-load-form-object-from-models)
6. [Save Form Object to Models](6-save-form-object-to-models)
   1. [Array of Form Objects and Models](61-array-of-form-objects-and-models)
7. [Serialize Form Object to Model Hash](7-serialize-form-object-to-model-hash)
8. [Validation and Coercion](8-validation-and-coercion)
9. [Copy Model Validation Errors into Form Object](9-copy-model-validation-errors-into-form-object)   
10. [Rails Example](10-rails-example)
11. [Reference Guide](11-reference-guide-attribute-parameters)

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

Team.new      # => FormObj::WrongDefaultValueClass: FormObj::WrongDefaultValueClass  
```

#### 1.2. Array of `FormObj::Struct`

Use parameter `array: true` in order to define an array of nested structs.
Define `primary_key` so that `update_attribute` method be able to distinguish 
whether to update existing array element or create a new one.  

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

Team.new      # => FormObj::WrongDefaultValueClass: FormObj::WrongDefaultValueClass  
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



















### 4. Using Form Object in Form Builder

Inherit your class from `FormObj::Form` in order to use it in form builder.

```ruby
class SimpleForm < FormObj::Form
  attribute :name
  attribute :year
end

@simple_form = SimpleForm.new
```

```erb
<%= form_for(@simple_form) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :year %>
  <%= f.text_field :year %>
<% end %>
```

#### 4.1. Nested Form Objects in Form Builder

```ruby
class NestedForm < FormObj::Form
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

@nested_form = NestedForm.new
```

```erb
<%= form_for(@nested_form) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :year %>
  <%= f.text_field :year %>

  <%= f.fields_for(:car) do |fc| %>
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
```

#### 4.2. Array of Form Objects in Form Builder

```ruby
class ArrayForm < FormObj::Form
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

@array_form = ArrayForm.new
```

```erb
<%= form_for(@array_form) do |f| %>
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

### 5. Map Form Object to/from Models

Include `ModelMapper` mix-in and map form object attributes to one or more models by using `:model` and `:model_attribute` parameters.
By default each form object attribute is mapped to the model attribute with the same name of the `:default` model. 

Use dot notation to map model attribute to a nested model. Use colon to specify a "hash" attribute.

```ruby
class SingleForm < FormObj::Form
  include ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model_attribute: 'car.:engine.power'
end
```

Suppose `single_form = SingleForm.new` and `model` to be an instance of a model.

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `single_form.name` | `model.team_name` |
| `single_form.year` | `model.year` |
| `single_form.engine_power` | `model.car[:engine].power` |

#### 4.1. Multiple Models Example

```ruby
class MultiForm < FormObj::Form
  include ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model: :car, model_attribute: ':engine.power'
end
```

Suppose `multi_form = MultiForm.new` and `default`, `car` to be instances of two models.

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `multi_form.name` | `default.team_name` |
| `multi_form.year` | `default.year` |
| `multi_form.engine_power` | `car[:engine].power` |

#### 4.2. Skip Attribute Mapping

Use `model_attribute: false` in order to avoid attribute mapping to the model.

```ruby
class SimpleForm < FormObj::Form
  include ModelMapper
  
   attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model_attribute: false
end
```

Suppose `form = SimpleForm.new` and `model` to be an instance of a model.

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `form.name` | `model.team_name` |
| `form.year` | `model.year` |
| `form.engine_power` | - |

#### 4.3. Map Nested Form Object Attribute to Parent Level Model Attribute

Use `model_nesting: false` for nested form object in order to map its attributes to the parent level of the model.

```ruby
class NestedForm < FormObj::Form
  include ModelMapper
    
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :car, model_nesting: false do   # nesting only in form object but not in a model
    attribute :code
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end
```

Suppose `form = NestedForm.new` and `model` to be an instance of a model.

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `form.name` | `model.team_name` |
| `form.year` | `model.year` |
| `form.car.code` | `model.code` |
| `form.car.driver` | `model.driver` |
| `form.car.engine.power` | `model.engine.power` |
| `form.car.engine.volume` | `model.engine.volume` |

#### 4.4. Map Nested Form Object to A Hash Model

Use `model_hash: true` in order to map a nested form object to a hash as a model.

```ruby
class NestedForm < FormObj::Form
  include ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :car, model_hash: true do   # nesting only in form object but not in a model
    attribute :code
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end
```

Suppose `form = NestedForm.new` and `model` to be an instance of a model.

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `form.name` | `model.team_name` |
| `form.year` | `model.year` |
| `form.car.code` | `model.car[:code]` |
| `form.car.driver` | `model.car[:driver]` |
| `form.car.engine.power` | `model.car[:engine].power` |
| `form.car.engine.volume` | `model.car[:engine].volume` |

### 5. Load Form Object from Models

Use `load_from_models(models)` to load form object attributes from mapped models. 
Method returns self so one can chain calls.

```ruby
class MultiForm < FormObj::Form
  include ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model: :car, model_attribute: ':engine.power'
end

default_model = Struct.new(:team_name, :year).new('Ferrari', 1950)
car_model = { engine: Struct.new(:power).new(335) }

multi_form = MultiForm.new.load_from_models(default: default_model, car: car_model)
multi_form.to_hash    # => {
                      # =>    :name => "Ferrari"
                      # =>    :year => 1950
                      # =>    :engine_power => 335
                      # => }
``` 

Use `load_from_models(default: model)` or `load_from_model(model)` to load from single model.

### 6. Sync Form Object to Models

Use `sync_to_models(models)` to sync form object attributes to mapped models.
Method returns self so one can chain calls.

```ruby
class MultiForm < FormObj::Form
  include ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model: :car, model_attribute: ':engine.power'
end

default_model = Struct.new(:team_name, :year).new('Ferrari', 1950)
car_model = { engine: Struct.new(:power).new(335) }

multi_form = MultiForm.new
multi_form.update_attributes(name: 'McLaren', year: 1966, engine_power: 415)
multi_form.sync_to_models(default: default_model, car: car_model)

default_model.name          # => "McLaren"
default_model.year          # => 1966
car_model[:engine].power    # => 415 
``` 

Use `sync_to_models(default: model)` or `sync_to_model(model)` to sync to single model.

Neither `sync_to_models` nor `sync_to_model` calls `save` method on the model(s).
Also they don't call `valid?` method on the model(s). 
Instead they just assign form object attributes value to mapped model attributes
using `<attribute_name>=` accessors on the model(s).

It is completely up to developer to do any additional validations on the model(s) and save it(them).

#### 6.1. Array of Form Objects and Models

Saving array of form objects to corresponding array of models requires the class of the model to be known by the form object
because it could create new instances of the model array elements.
Use `:model_class` parameter to specify it. 
Form object will try to guess the name of the class from the name of the attribute if this parameter is absent.

```ruby
class ArrayForm < FormObj::Form
  include ModelMapper
  
  attribute :name
  attribute :year
  attribute :cars, array: true, model_class: Car do
    attribute :code, primary_key: true     # <- primary key is specified on attribute level
    attribute :driver
  end
end
``` 

If corresponding `:model_attribute` parameter uses dot notations to reference
nested models the value of `:model_class` parameter should be an array of corresponding model classes.

```ruby
class ArrayForm < FormObj::Form
  include ModelMapper
  
  attribute :name
  attribute :year
  attribute :cars, array: true, model_attribute: 'equipment.cars', model_class: [Equipment, Car] do
    attribute :code, primary_key: true     # <- primary key is specified on attribute level
    attribute :driver
  end
end
``` 

### 7. Serialize Form Object to Model Hash

Use `to_model_hash(model = :default)` to get hash representation of the model that mapped to the form object.

```ruby
class MultiForm < FormObj::Form
  include ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model: :car, model_attribute: ':engine.power'
end

multi_form = MultiForm.new
multi_form.update_attributes(name: 'McLaren', year: 1966, engine_power: 415)

multi_form.to_model_hash              # => { :team_name => "McLaren", :year => 1966 }
multi_form.to_model_hash(:default)    # => { :team_name => "McLaren", :year => 1966 }
multi_form.to_model_hash(:car)        # => { :engine => { :power => 415 } }
``` 

Use `to_models_hash()` to get hash representation of all models that mapped to the form object.

```ruby
multi_form.to_models_hash             # => {
                                      # =>   default: { :team_name => "McLaren", :year => 1966 }
                                      # =>   car: { :engine => { :power => 415 } }
                                      # => } 
``` 

If array of form objects mapped to the parent model (`model_attribute: false`) it is serialized to `:self` key.

```ruby
class ArrayForm < FormObj::Form
  include ModelMapper
  
  attribute :name
  attribute :year
  attribute :cars, array: true, model_attribute: false do
    attribute :code, primary_key: true
    attribute :driver
  end
end

array_form = ArrayForm.new
array_form.update_attributes(
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

array_form.to_model_hash    # => { 
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

### 8. Validation and Coercion

Form Object is just a Ruby class. By default it includes (could be changed in future releases):

```ruby
  extend ::ActiveModel::Naming
  extend ::ActiveModel::Translation

  include ::ActiveModel::Conversion
  include ::ActiveModel::Validations
```

So add ActiveModel validations directly to Form Object class definition.

```ruby
class MultiForm < FormObj::Form
  include ModelMapper
  
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model: :car, model_attribute: ':engine.power'
  
  validates :name, :year, presence: true
end
```

There is no coercion during assigning/updating form object attributes. 
Coercion can be done manually by redefining assigning methods `<attribute_name>=`
or it will happen in the model when the form object will be saved to it. 
This is the standard way how coercion happens in Rails for example.  

### 9. Copy Model Validation Errors into Form Object

Even though validation could and should happen in the form object it is possible to have (additional) validation(s) in the model(s).
In this case it is handy to copy model validation errors to form object in order to be able to present them to the user in a standard way.

Use `copy_errors_from_models(models)` or `copy_errors_from_model(model)` in order to do it.
Methods return self so one can chain calls.

```ruby
multi_form.copy_errors_from_models(default: default_model, car: car_model)
``` 

In case of single model:
```ruby
single_form.copy_errors_from_model(model)
```

### 10. Rails Example

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
  include ModelMapper
  
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

### 11. Reference Guide: `attribute` parameters

| Parameter | Condition | Default value | Defined in | Description |
| --- |:---:|:---:|:---:| --- |
| array | block* or `:class`** | `false` | `FormObj::Struct` | This attribute is an array of form objects. The structure of array element form object is described either in the block or in the separate class referenced by `:class` parameter |
| class | - | - | `FormObj::Struct` | This attribute is either nested form object or array of form objects. The value of this parameter is the class of this form object or the name of the class. |
| default | - | - | `FormObj::Struct` | Defines default value for the attribute. Nested structures default value can be defined either with Hash or with object. | 
| model_hash | block* or `:class`** | `false` | `FormObj::ModelMapper` | This attribute is either nested form object or array of form objects. This form object is mapped to a model of the class `Hash` so all its attributes should be accessed by `[:<attribute_name>]` instead of `.<attribute_name>` | 
| model | - | `:default` | `FormObj::ModelMapper` | The name of the model to which this attribute is mapped |
| model_attribute | - | `<attribute_name>` | `FormObj::ModelMapper` | The name of the model attribute to which this form object attribute is mapped. Dot notation is used in order to map to nested model, ex. `"car.engine.power"`. Colon is used in front of the name if the model is hash, ex. `"car.:engine.power"` - means call to `#car` returns `Hash` so the model attribute should be accessed like `car[:engine].power`. `false` value means that attribute is not mapped. |
| model_class | block* or `:class`** or dot notation for `:model_attribute`*** | `<attribute_name>.classify` | `FormObj::ModelMapper` | The class (or the name of the class) of the mapped model. |
| model_nesting | block* or `:class`** | `true` | `FornObj::ModelMapper` | If attribute describes nested form object and has `model_nesting: false` the attributes of nested form will be called on the parent (upper level) model. If attribute describes array of form objects and has `model_nesting: false` the methods to access array elements (`:[]` etc.) will be called on the parent (upper level) model. | 
| primary_key | no block* and no `:class`** | `false` | `FormObj::Struct` | This attribute is the primary key of the form object. The mapped model attribute is considered to be a primary key for the corresponding model. |
| primary_key | block* or `:class`** | - | `FormObj::Struct` | This attribute is either nested form object or array of form objects. The value of this parameter is the name of the primary key attribute of this form object. |
\* block - means that there is block definition for the attribute

\** `:class` - means that this attribute has `:class` parameter specified

\*** dot notation for `:model_attribute` - means that this attribute is mapped to nested model attribute (using dot notation)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akoltun/form_obj.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
