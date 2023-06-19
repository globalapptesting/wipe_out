ENV["RAILS_ENV"] = "test"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start
end

require_relative "../lib/wipe_out"

require "combustion"
require "factory_bot"
require "sqlite3"
require "pry"
require "super_diff/rspec"
require "super_diff/active_support"

Combustion.initialize!(:active_record)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = meta.fetch(:aggregate_failures, true)
  end

  config.raise_errors_for_deprecations!
end
