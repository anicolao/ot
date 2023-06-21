# frozen_string_literal: true

require 'yaml'
require 'open3'

class Operator
  attr_reader :name, :pipeline

  def initialize(name:, pipeline:)
    @name = name
    @pipeline = pipeline
  end

  def exec(args:, input_stream:)
    parameterized_pipeline = pipeline.map { |p| p % args }

    # Connect stdin to the input stream only for the first segment of the pipeline
    parameterized_pipeline[0] = [{}, parameterized_pipeline[0], { $stdin => input_stream }]

    Open3.pipeline_r(*parameterized_pipeline, unsetenv_others: true) do |last_stdout, _wait_threads|
      last_stdout.read
    end
  end
end
