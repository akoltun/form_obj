require "test_helper"
require 'action_view'

ver = Gem::Version.new(ActiveSupport::VERSION::STRING)
if Gem::Version.new('3.2') <= ver && ver < Gem::Version.new('4.0')
  require 'action_controller'
elsif Gem::Version.new('4.0') <= ver && ver < Gem::Version.new('5.0')
  require 'active_support/core_ext/hash' # Used by form builder
end

class ModelMapperFormBuilderTest < Minitest::Test
  ver = Gem::Version.new(ActiveSupport::VERSION::STRING)
  if Gem::Version.new('3.2') <= ver && ver < Gem::Version.new('4.0')
    include ActionController::RecordIdentifier
  elsif Gem::Version.new('4.0') <= ver && ver < Gem::Version.new('5.0')
    include ActionView::RecordIdentifier
  end

  include ActionView::Context
  include ActionView::Helpers::FormHelper

  def protect_against_forgery?
    false
  end

  class Team < FormObj::Form
    include FormObj::ModelMapper

    attribute :name
    attribute :year
    attribute :cars, array: true, default: [{code: 'M1'}, {code: 'M2'}], primary_key: :code do
      attribute :code
      attribute :driver
      attribute :engine do
        attribute :power
        attribute :volume
      end
    end
  end

  def setup
    # _prepare_context

    team = Team.new

    @render = form_for team, url: '/team' do |f|
      concat f.text_field :name
      team.cars.each do |car|
        concat(f.fields_for(:cars, car, index: '') do |fc|
          concat fc.text_field :code
          concat(fc.fields_for(:engine) do |fce|
            concat fce.text_field :power
            concat fce.text_field :volume
          end)
          concat fc.text_field :driver
        end)
      end
      concat f.text_field :year
    end
  end

  def test_that_it_renders_all_input_elements
    assert_match(/<input( \w+="[^"]+")* name="\w+\[name\]"( \w+="[^"]+")* \/>/, @render)
    assert_match(/<input( \w+="[^"]+")* name="\w+\[year\]"( \w+="[^"]+")* \/>/, @render)
    assert_match(/<input( \w+="[^"]+")* name="\w+\[cars\]\[\]\[code\]"( \w+="[^"]+")* \/>/, @render)
    assert_match(/<input( \w+="[^"]+")* name="\w+\[cars\]\[\]\[driver\]"( \w+="[^"]+")* \/>/, @render)
    assert_match(/<input( \w+="[^"]+")* name="\w+\[cars\]\[\]\[engine\]\[power\]"( \w+="[^"]+")* \/>/, @render)
    assert_match(/<input( \w+="[^"]+")* name="\w+\[cars\]\[\]\[engine\]\[volume\]"( \w+="[^"]+")* \/>/, @render)
  end
end
