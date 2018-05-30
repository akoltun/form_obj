require "bundler/setup"
require "form_obj"
require 'action_view'
require 'action_pack'
require 'action_controller'
require 'active_support/core_ext/hash' # Used by form builder

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end

RSpec.shared_context 'renderable' do
  if Gem::Version.new(ActionPack::VERSION::STRING) >= Gem::Version.new('4.0')
    include ActionView::RecordIdentifier
  else
    include ActionController::RecordIdentifier
  end
  include ActionView::Context
  include ActionView::Helpers::FormHelper

  before { _prepare_context }

  def protect_against_forgery?
    false
  end
end