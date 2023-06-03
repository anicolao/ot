# frozen_string_literal: true

ENV['ENV'] = 'test'

require 'byebug'
require 'json'
require 'simplecov'

threshold_file_path = File.join(__dir__, '.coverage_thresholds.json')
coverage_thresholds = JSON.parse(File.read(threshold_file_path), symbolize_names: true)

SimpleCov.start do
  enable_coverage :branch
  primary_coverage :branch
  add_filter %r{^/spec/*}
  minimum_coverage coverage_thresholds

  add_group 'Lib', 'lib'
  add_group 'Cmds', 'cmds'
end

SimpleCov.refuse_coverage_drop

SimpleCov.enable_for_subprocesses true
SimpleCov.at_fork do |pid|
  # This needs a unique name so it won't be overwritten
  SimpleCov.command_name "#{SimpleCov.command_name} (subprocess: #{pid})"
  # be quiet, the parent process will be in charge of output and checking coverage totals
  SimpleCov.print_error_status = false
  SimpleCov.formatter SimpleCov::Formatter::SimpleFormatter
  SimpleCov.minimum_coverage 0
  # start
  SimpleCov.start
end

pid = Process.pid
SimpleCov.at_exit do
  if Process.pid == pid
    # Update thresholds automatically when coverage increases
    line_coverage = SimpleCov.result.coverage_statistics.fetch(:line).percent
    branch_coverage = SimpleCov.result.coverage_statistics.fetch(:branch).percent
    new_coverage_thresholds = {
      line: [coverage_thresholds.fetch(:line), (line_coverage - 0.1).floor(1)].max,
      branch: [coverage_thresholds.fetch(:branch), (branch_coverage - 0.1).floor(1)].max
    }
    puts "Coverage report:\n\n"
    puts 'Coverage html output in coverage/index.html'
    if coverage_thresholds == new_coverage_thresholds
      puts "#{threshold_file_path} used to determine coverage criteria. Update this file if needed"
    else
      puts "Coverage threshold file #{threshold_file_path} automatically updated"
      File.write(threshold_file_path, JSON.pretty_generate(new_coverage_thresholds))
    end

    puts "Line coverage: #{line_coverage.round(2)}. Minimum set to #{coverage_thresholds.fetch(:line)}"
    puts "Branch coverage: #{branch_coverage.round(2)}. Minimum set to #{coverage_thresholds.fetch(:branch)}"
    puts "\n"
  end

  SimpleCov.result.format!
end

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

  config.around :each do |each|
    Dir.mktmpdir do |dir|
      old_home_dir = ENV['HOME']
      ENV['HOME'] = dir
      each.run
      ENV['HOME'] = old_home_dir
    end
  end
end
