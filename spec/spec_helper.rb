require "bundler/setup"
require "form_obj"
require 'action_view'
require 'action_pack'
require 'action_controller'

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
  include ActionController::RecordIdentifier
  include ActionView::Context
  include ActionView::Helpers::FormHelper

  before { _prepare_context }

  def protect_against_forgery?
    false
  end
end