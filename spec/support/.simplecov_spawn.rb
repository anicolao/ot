# frozen_string_literal: true

require 'simplecov' # this will also pick up whatever config is in .simplecov
# so ensure it just contains configuration, and doesn't call SimpleCov.start.

SimpleCov.command_name 'spawn' # As this is not for a test runner directly,
# script doesn't have a pre-defined base command_name

SimpleCov.at_fork.call(Process.pid) # Use the per-process setup described previously
SimpleCov.start # only now can we start.
