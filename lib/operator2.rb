# frozen_string_literal: true

require 'yaml'
require 'open3'

class Operator2
  MAGIC_MARKER = '>><<'

  attr_reader :name, :pipeline

  def initialize(name:, pipeline:)
    @name = name
    @pipeline = pipeline
  end

  def serialize(args:, content:)
    serialized_args = self.class.serialized_hash(args)
    serialized_pipeline = self.class.serialized_array(pipeline)
    "#{MAGIC_MARKER}#{self.class.serialized_string(name)}#{serialized_pipeline}#{serialized_args}#{self.class.serialized_string(content)}"
  end

  def exec(args:, input_stream:)
    parameterized_pipeline = pipeline.map { |p| p % args }

    # Connect stdin to the input stream only for the first segment of the pipeline
    parameterized_pipeline[0] = [{}, parameterized_pipeline[0], $stdin => input_stream]

    Open3.pipeline_r(*parameterized_pipeline, unsetenv_others: true) do |last_stdout, wait_threads|
      last_stdout.read
    end
  end

  class << self
    def hydrate(stream:)
      return nil if stream.eof

      magic_marker = get_marker(stream)
      raise ArgumentError, 'Magic marker not found' unless magic_marker == MAGIC_MARKER

      name = get_string(stream)
      pipeline = get_pipeline(stream)
      args = get_args(stream)
      content = get_string(stream)

      [new(name: name, pipeline: pipeline), args, content]
    end

    def is_operator_content?(content)
      content.start_with?(MAGIC_MARKER)
    end

    def serialized_array(array)
      "#{[array.count].pack('C')}#{array.map { |el| serialized_string(el) }.join}"
    end

    def serialized_hash(hash)
      "#{[hash.count].pack('C')}#{hash.map { |k, v| "#{serialized_string(k)}#{serialized_string(v)}" }.join}"
    end

    def serialized_string(s)
      len = s.bytes.length
      ([len] + s.bytes).pack("LC#{len}")
    end

    def get_marker(stream)
      stream.read(4)
    end

    def get_pipeline(stream)
      array_count = stream.read(1).unpack('C')[0]
      array_count.times.map { get_string(stream) }
    end

    def get_args(stream)
      array_count = stream.read(1).unpack('C')[0]
      array_count.times.reduce({}) do |_, acc|
        key = get_string(stream)
        value = get_string(stream)
        acc[key] = value
        acc
      end
    end

    def get_string(stream)
      len = stream.read(4).unpack('L')[0]
      stream.read(len)
    end
  end
end
