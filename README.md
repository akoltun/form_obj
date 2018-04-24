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
**WARNING!!!** Documentation is still under development. All working examples could be taken from the tests.

### Definition

Inherit your class from `FormObj` and define its attributes.

```ruby
class SimpleForm < FormObj
  attribute :name
  attribute :year
end
```

Use it in form builder.

```ruby
<%= form_for(@simple_form) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :year %>
  <%= f.text_field :year %>
<% end %>
```

#### Nested Form Objects

Use blocks to define nested forms.

```ruby
class NestedForm < FormObj
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
class EngineForm < FormObj
  attribute :power
  attribute :volume
end
class CarForm < FormObj
  attribute :model
  attribute :driver
  attribute :engine, class: EngineForm
end
class NestedForm < FormObj
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

#### Array of Form Objects

Specify attribute parameter `array: true` in order to define an array of form objects

```ruby
class ArrayForm < FormObj
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
class EngineForm < FormObj
  attribute :power
  attribute :volume
end
class CarForm < FormObj
  attribute :model
  attribute :driver
  attribute :engine, class: EngineForm
end
class ArrayForm < FormObj
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

### Update Attributes

Update form object attributes with the parameter hash received from the browser.

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

#### Nested Form Objects

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

#### Array of Form Objects

Updating array of form objects will compare the existing array and the new one.
New array elements will be added, existing array elements will be updated, absent array elements will be deleted 
(deleting behaviour is the subject of changes in future releases - only elements with flag _destroy == true will be deleted).

In order to compare old and new array its elements have to be identified via the primary key.
Primary key can be specified either on the attribute level or on the form level.
If it is not specified the :id field is supposed to be a primary key.

```ruby
class ArrayForm < FormObj
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
class ArrayForm < FormObj
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

### Serialize to Hash

Call `to_hash` method in order to get hash representation of the form object

```ruby
simple_form.to_hash     # => {
                        # =>    :name => "McLaren",
                        # =>    :year => 1966  
                        # => }
```

#### Nested Form Objects

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

#### Array of Form Objects

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

### Map Form Object to Models

Map form object attributes to one or few models by using `:model` and `:model_attribute` parameters.
By default each form object attribute is mapped to the model attribute with the same name of the `:default` model. 

Use dot notation to map model attribute to nested model. Use colon to specify "hash" attribute.

```ruby
class SimpleForm < FormObj
  attribute :name, model_attribute: :team_name
  attribute :year
  attribute :engine_power, model_attribute: 'car.:engine.power'
end
```

Suppose `form = SimpleForm.new` and `model` to be an instance of a model.

| Form Object attribute | Model attribute |
| --------------------- | --------------- |
| `form.name` | `model.team_name` |
| `form.year` | `model.year` |
| `form.engine_power` | `model.car[:engine].power` |

#### Multiple Models Example

```ruby
class MultiForm < FormObj
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

#### Skip Attribute Mapping (not implemented yet)

Use `model_attribute: false` in order to avoid attribute mapping to the model.

```ruby
class SimpleForm < FormObj
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

##### Map Nested Form Object Attribute to Parent Level Model Attribute

Use `model_attribute: false` for nested form object in order to map its attributes to the parent level of the model.

```ruby
class NestedForm < FormObj
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

#### Map Nested Form Object to A Hash Model

Use `hash: true` in order to map a nested form object to a hash as a model.

```ruby
class NestedForm < FormObj
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

### Load Form Object from Models

...

### Save Form Object to Models

...

### Serialize Form Object to Model Hash

...

### Copy Model Errors into Form Object

... 

### Rails example

...

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akoltun/form_obj.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
