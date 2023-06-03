# frozen_string_literal: true

require 'simplecov'
require 'json'

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

SimpleCov.at_exit do
  # Update thresholds automatically when coverage increases
  line_coverage = SimpleCov.result.coverage_statistics.fetch(:line).percent
  branch_coverage = SimpleCov.result.coverage_statistics.fetch(:branch).percent
  new_coverage_thresholds = {
    line: [coverage_thresholds.fetch(:line), (line_coverage - 0.1).floor(1)].max,
    branch: [coverage_thresholds.fetch(:branch), (branch_coverage - 0.1).floor(1)].max
  }
  puts "Coverage report:\n\n"
  puts "Coverage html output in coverage/index.html"
  if coverage_thresholds != new_coverage_thresholds
    puts "Coverage threshold file #{threshold_file_path} automatically updated"
    File.write(threshold_file_path, JSON.pretty_generate(new_coverage_thresholds))
  else
    puts "#{threshold_file_path} used to determine coverage criteria. Update this file if needed"
  end

  puts "Line coverage: #{line_coverage.round(2)}. Minimum set to #{coverage_thresholds.fetch(:line)}"
  puts "Branch coverage: #{branch_coverage.round(2)}. Minimum set to #{coverage_thresholds.fetch(:branch)}"
  puts "\n"

  SimpleCov.result.format!
end
