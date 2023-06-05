# frozen_string_literal: true

ENV['ENV'] = 'test'

require 'byebug'
require 'simplecov'
SimpleCov.start

require_relative './support'
require_relative '../lib'

RSpec.configure do |config|
  config.include PipeHelpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run_when_matching :focus

  config.disable_monkey_patching!

  config.warnings = false

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed
end
