# frozen_string_literal: true

require 'yaml'
require 'open3'

class Operator
  attr_reader :name, :pipeline

  def initialize(name:, pipeline:)
    @name = name
    @pipeline = pipeline
    #TODO: assert that each pipeline segment is interpolation-ready
  end

  def exec(input_stream:, args: {})
    parameterized_pipeline = pipeline.map { |p| p % args }

    # Connect stdin to the input stream only for the first segment of the pipeline
    parameterized_pipeline[0] = [{}, parameterized_pipeline[0], { $stdin => input_stream }]

    output = Open3.pipeline_r(*parameterized_pipeline, unsetenv_others: true) do |last_stdout, _wait_threads|
      last_stdout.read
    end
    block_given? ? yield(output) : output
  end
end
