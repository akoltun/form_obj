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

### Update attributes

...

### Serialize to hash

...

### 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akoltun/form_obj.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
