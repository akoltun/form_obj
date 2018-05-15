# FormObj

Form Object allows to describe complicated data structure (nesting, arrays) and use it with Rails-cmpatible form builders.
Form Object can serialize and deserialize itself to/from model and hash.

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

**WARNING!!!** The gem is still under development. Expecting braking changes.<br/>

Form Object `FormObj::Form` is inherited from `TreeStruct` (https://github.com/akoltun/tree_struct).

### Table of Contents

1. [Definition](#1-definition)
   1. [Nested Form Objects](11-nested-form-objects)
   2. [Array of Form Objects](12-array-of-form-objects)
2. [Update Attributes](2-update-attributes)
   1. [Nested Form Objects](21-nested-form-objects)
   2. [Array of Form Objects](22-array-of-form-objects)
3. [Serialize to Hash](3-serialize-to-hash)
   1. [Nested Form Objects](31-nested-form-objects)
   2. [Array of Form Objects](32-array-of-form-objects)
4. [Map Form Object to Models](4-map-form-objects-to-models)
   1. [Multiple Models Example](41-multiple-models-example)
   2. [Skip Attribute Mapping (not implemented yet)](42-skip-attribute-mapping)
      1. [Map Nested Form Object Attribute to Parent Level Model Attribute](421-map-nested-form-object-attribute-to-parent-level-model-attribute)
   3. [Map Nested Form Object to A Hash Model](43-map-nested-form-object-to-a-hash-model)
5. [Load Form Object from Models](5-load-form-object-from-models)
6. [Save Form Object to Models](6-save-form-object-to-models)
   1. [Array of Form Objects and Models](61-array-of-form-objects-and-models)
7. [Serialize Form Object to Model Hash](7-serialize-form-object-to-model-hash)
8. [Validation and Coercion](8-validation-and-coercion)
9. [Copy Model Validation Errors into Form Object](9-copy-model-validation-errors-into-form-object)   
10. [Rails Example](10-rails-example)
11. [Reference Guide](11-reference-guide-attribute-parameters)

### 1. Definition

Inherit your class from `FormObj` and define its attributes.

```ruby
class SimpleForm < FormObj
  attribute :name
  attribute :year
end
```

Use it in form builder.

```erb
<%= form_for(@simple_form) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :year %>
  <%= f.text_field :year %>
<% end %>
```

#### 1.1. Nested Form Objects

Use blocks to define nested forms.

```ruby
class NestedForm < FormObj::Form
  attribute :name
  attribute :year
  attribute :car do
    attribute :model
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end
```

Or explicitly define nested form class.

```ruby
class EngineForm < FormObj::Form
  attribute :power
  attribute :volume
end
class CarForm < FormObj::Form
  attribute :model
  attribute :driver
  attribute :engine, class: EngineForm
end
class NestedForm < FormObj::Form
  attribute :name
  attribute :year
  attribute :car, class: CarForm
end
```

Use nested forms in form builder.

```ruby
<%= form_for(@nested_form) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :year %>
  <%= f.text_field :year %>

  <%= f.fields_for(:car) do |fc| %>
    <%= fc.label :model %>
    <%= fc.text_field :model %>

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

#### 1.2. Array of Form Objects

Specify attribute parameter `array: true` in order to define an array of form objects

```ruby
class ArrayForm < FormObj::Form
  attribute :name
  attribute :year
  attribute :cars, array: true do
    attribute :model
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
class EngineForm < FormObj::Form
  attribute :power
  attribute :volume
end
class CarForm < FormObj::Form
  attribute :model
  attribute :driver
  attribute :engine, class: EngineForm
end
class ArrayForm < FormObj::Form
  attribute :name
  attribute :year
  attribute :cars, array: true, class: CarForm
end
```

Add new elements in the array by using method :create on which adds a new it.

```ruby
array_form = ArrayForm.new
array_form.size 				# => 0
array_form.cars.create
array_form.size 				# => 1
```

### 2. Update Attributes

Update form object attributes with the parameter hash received from the browser. 
Method `update_attributes` returns self so one can chain calls.

```ruby
simple_form = SimpleForm.new
simple_form.name = 'Ferrari'
simple_form.year = 1950
simple_form.update_attributes(
                                name: 'McLaren',
                                year: 1966
                             )
simple_form.name      # => "McLaren"                             
simple_form.year      # => 1966                             
```

#### 2.1. Nested Form Objects

```ruby
nested_form = NestedForm.new
nested_form.name = 'Ferrari'
nested_form.year = 1950
nested_form.car.model = '340 F1'
nested_form.car.driver = 'Ascari'
nested_form.car.engine.power = 335
nested_form.car.engine.volume = 4.1
nested_form.update_attributes(
                                name: 'McLaren',
                                year: 1966,
                                car: {
                                  model: 'M2B',
                                  driver: 'Bruce McLaren',
                                  engine: {
                                    power: 300,
                                    volume: 3.0
                                  }
                                }
                             )
nested_form.name                  # => "McLaren"
nested_form.year                  # => 1966
nested_form.car.model             # => "M2B"
nested_form.car.driver            # => "Bruce McLaren"
nested_form.car.engine.power      # => 300
nested_form.car.engine.volume     # => 3.0
```

#### 2.2. Array of Form Objects

Updating array of form objects will compare the existing array and the new one.
New array elements will be added, existing array elements will be updated, absent array elements will be deleted 
(deleting behaviour is the subject of changes in future releases - only elements with flag _destroy == true will be deleted).

In order to compare old and new array its elements have to be identified via the primary key.
Primary key can be specified either on the attribute level or on the form level.
If it is not specified the :id field is supposed to be a primary key.

```ruby
class ArrayForm < FormObj::Form
  attribute :name
  attribute :year
  attribute :cars, array: true do
    attribute :model, primary_key: true     # <- primary key is specified on attribute level
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end
``` 

```ruby
class ArrayForm < FormObj::Form
  attribute :name
  attribute :year
  attribute :cars, array: true, primary_key: :model do     # <- primary key is specified on form level
    attribute :model
    attribute :driver
    attribute :engine do
      attribute :power
      attribute :volume
    end
  end
end
``` 

```ruby
array_form = ArrayForm.new
array_form.name = 'Ferrari'
array_form.year = 1950

car1 = array_form.cars.create
car1.model = '340 F1'
car1.driver = 'Ascari'
car1.engine.power = 335
car1.engine.volume = 4.1

car2 = array_form.cars.create
car2.model = 'M2B'
car2.driver = 'Villoresi'
car2.engine.power = 300
car2.engine.volume = 3.3

array_form.update_attributes(
                              name: 'McLaren',
                              year: 1966,
                              cars: [
                                  {
                                      model: 'M2B',
                                      driver: 'Bruce McLaren',
                                      engine: {
                                          volume: 3.0
                                      }
                                  }, {
                                      model: 'M7A',
                                      driver: 'Denis Hulme',
                                      engine: {
                                          power: 415,
                                      }
                                  }
                              ],
                            )
                            
array_form.name                     # => "McLaren"
array_form.year                     # => 1966

array_form.cars[0].model            # => "M2B"
array_form.cars[0].driver           # => "Bruce McLaren"
array_form.cars[0].engine.power     # => 300    - this value was not updated in update_attributes
array_form.cars[0].engine.volume    # => 3.0

array_form.cars[1].model            # => "M7A"
array_form.cars[1].driver           # => "Denis Hulme"
array_form.cars[1].engine.power     # => 415
array_form.cars[1].engine.volume    # => nil    - this value is nil because this car was created in updated_attributes
```

### 3. Serialize to Hash

Call `to_hash` method in order to get hash representation of the form object

```ruby
simple_form.to_hash     # => {
                        # =>    :name => "McLaren",
                        # =>    :year => 1966  
                        # => }
```

#### 3.1. Nested Form Objects

```ruby
nested_form.to_hash     # => {
                        # =>    :name => "McLaren",
                        # =>    :year => 1966,
                        # =>    :car  => {
                        # =>      :model => "340 F1",
                        # =>      :driver => "Ascari",
                        # =>      :engine => {
                        # =>        :power => 335,
                        # =>        :volume => 4.1
                        # =>      }   
                        # =>    }
                        # => }
```

#### 3.2. Array of Form Objects

```ruby
array_form.to_hash      # => {
                        # =>    :name => "McLaren",
                        # =>    :year => 1966,
                        # =>    :cars => [{
                        # =>      :model => "M2B",
                        # =>      :driver => "Bruce McLaren",
                        # =>      :engine => {
                        # =>        :power => 300,
                        # =>        :volume => 3.0
                        # =>      }
                        # =>    }, {
                        # =>      :model => "M7A",
                        # =>      :driver => "Denis Hulme",
                        # =>      :engine => {
                        # =>        :power => 415,
                        # =>        : volume => nil
                        # =>      }
                        # =>    }] 
                        # => }
```

### 4. Map Form Object to Models

Map form object attributes to one or few models by using `:model` and `:model_attribute` parameters.
By default each form object attribute is mapped to the model attribute with the same name of the `:default` model. 

Use dot notation to map model attribute to nested model. Use colon to specify "hash" attribute.

```ruby
class SingleForm < FormObj::Form
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

#### 4.2. Skip Attribute Mapping (not implemented yet)

Use `model_attribute: false` in order to avoid attribute mapping to the model.

```ruby
class SimpleForm < FormObj::Form
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

##### 4.2.1. Map Nested Form Object Attribute to Parent Level Model Attribute

Use `model_attribute: false` for nested form object in order to map its attributes to the parent level of the model.

```ruby
class NestedForm < FormObj::Form
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :car, model_attribute: false do   # nesting only in form object but not in a model
    attribute :model
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
| `form.car.model` | `model.model` |
| `form.car.driver` | `model.driver` |
| `form.car.engine.power` | `model.engine.power` |
| `form.car.engine.volume` | `model.engine.volume` |

#### 4.3. Map Nested Form Object to A Hash Model

Use `hash: true` in order to map a nested form object to a hash as a model.

```ruby
class NestedForm < FormObj::Form
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :car, hash: true do   # nesting only in form object but not in a model
    attribute :model
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
| `form.car.model` | `model.car[:model]` |
| `form.car.driver` | `model.car[:driver]` |
| `form.car.engine.power` | `model.car[:engine].power` |
| `form.car.engine.volume` | `model.car[:engine].volume` |

### 5. Load Form Object from Models

Use `load_from_models` to load form object attributes from mapped models. 
Method returns self so one can chain calls.

```ruby
class MultiForm < FormObj::Form
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

### 6. Save Form Object to Models

Use `save_to_models` to save form object attributes to mapped models.
Method returns self so one can chain calls.

```ruby
class MultiForm < FormObj::Form
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model: :car, model_attribute: ':engine.power'
end

default_model = Struct.new(:team_name, :year).new('Ferrari', 1950)
car_model = { engine: Struct.new(:power).new(335) }

multi_form = MultiForm.new
multi_form.update_attributes(name: 'McLaren', year: 1966, engine_power: 415)
multi_form.save_to_models(default: default_model, car: car_model)

default_model.name          # => "McLaren"
default_model.year          # => 1966
car_model[:engine].power    # => 415 
``` 

Use `save_to_models(default: model)` or `save_to_model(model)` to save to single model.

Neither `save_to_models` nor `save_to_model` calls `save` method on the model(s).
Also they don't call `valid?` method on the model(s). 
Instead they just assign form object attributes values to mapped model attributes
using `<attribute_name>=` accessors on the model(s).

It is completely up to developer to do any additional validations on the model(s) and save it(them).

#### 6.1. Array of Form Objects and Models

Saving array of form objects to corresponding array of models requires the class of the model to be known by the form object
because it could create new instances of the model array elements.
Use `:model_class` parameter to specify it. 
Form object will try to guess the name of the class from the name of the attribute if this parameter is absent.

```ruby
class ArrayForm < FormObj::Form
  attribute :name
  attribute :year
  attribute :cars, array: true, model_class: Car do
    attribute :model, primary_key: true     # <- primary key is specified on attribute level
    attribute :driver
  end
end
``` 

If corresponding `:model_attribute` parameter uses dot notations to reference
nested models the value of `:model_class` parameter should be an array of corresponding model classes.

```ruby
class ArrayForm < FormObj::Form
  attribute :name
  attribute :year
  attribute :cars, array: true, model_attribute: 'equipment.cars', model_class: [Equipment, Car] do
    attribute :model, primary_key: true     # <- primary key is specified on attribute level
    attribute :driver
  end
end
``` 

### 7. Serialize Form Object to Model Hash

Use `to_model_hash` to get hash representation of model which mapped to the form object.

```ruby
class MultiForm < FormObj::Form
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

The `:default` model is considered if it is not specified.

If array of form objects mapped to the parent model (`model_attribute: false`) it is serialized to `:self` key.

```ruby
class ArrayForm < FormObj::Form
  attribute :name
  attribute :year
  attribute :cars, array: true, model_attribute: false do
    attribute :model, primary_key: true
    attribute :driver
  end
end

array_form = MultiForm.new
array_form.update_attributes(
    name: 'McLaren', 
    year: 1966, 
    cars: [{
      model: 'M2B', 
      driver: 'Bruce McLaren'
    }, {
      model: 'M7A',
      driver: 'Denis Hulme'
    }]
)

array_form.to_model_hash    # => { 
                            # =>    :team_name => "McLaren", 
                            # =>    :year => 1966,
                            # =>    :self => {
                            # =>      :model => "M2B",
                            # =>      :driver => "Bruce McLaren"
                            # =>    }, {    
                            # =>      :model => "M7A",
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

Use `copy_errors_from_models` or `copy_errors_from_model` in order to do it.
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
      t.string :model
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
  attribute :id
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :cars, array: true do
    attribute :id
    attribute :model
    attribute :engine_power, model_attribute: 'engine.:power'
    
    validates :model, presence: true
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
      @team.save_to_model(model = Team.new) 
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
      @team.save_to_model(model)
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
    <li><%= car.model %> (<%= car.engine[:power] %> hp)</li>    
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
    <%= cf.text_field :model %>
    <%= cf.link_to_remove 'Remove the Car' %> 
  <% end %>
  <%= f.link_to_add 'Add a Car', :cars %>
<% end %>
```

### 11. Reference Guide: `attribute` parameters

| Parameter | Condition | Default value | Description |
| --- |:---:|:---:| --- |
| array | block* or `:class`** | `false` | This attribute is an array of form objects. The structure of array element form object is described either in the block or in the separate class referenced by `:class` parameter |
| class | - | - | This attribute is either nested form object or array of form objects. The value of this parameter is the class of this form object or the name of the class. |
| hash | block* or `:class`** | `false` | This attribute is either nested form object or array of form objects. This form object is mapped to a model of the class `Hash` so all its attributes should be accessed by `[:<attribute_name>]` instead of `.<attribute_name>` | 
| model | - | `:default` | The name of the model to which this attribute is mapped |
| model_attribute | - | `<attribute_name>` | The name of the model attribute to which this form object attribute is mapped. Dot notation is used in order to map to nested model, ex. `"car.engine.power"`. Colon is used in front of the name if the model is hash, ex. `"car.:engine.power"` - means call to `#car` returns `Hash` so the model attribute should be accessed like `car[:engine].power`. `false` value means that attribute is not mapped. If attribute describes nested form object and has `model_attribute: false` the attributes of nested form will be called on the parent (upper level) model. If attribute describes array of form objects and has `model_attribute: false` the methods to access array elements (`:[]` etc.) will be called on the parent (upper level) model. |
| model_class | block* or `:class`** or dot notation for `:model_attribute`*** | `<attribute_name>.classify` | The class (or the name of the class) of the mapped model. |
| primary_key | no block* and no `:class`** | `false` | This attribute is the primary key of the form object. The mapped model attribute is considered to be a primary key for the corresponding model. |
| primary_key | block* or `:class`** | - | This attribute is either nested form object or array of form objects. The value of this parameter is the name of the primary key attribute of this form object. |
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
