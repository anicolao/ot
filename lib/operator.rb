# frozen_string_literal: true

require 'yaml'
require 'open3'

class Operator
  MAGIC_MARKER = '>><<'

  attr_reader :name, :pipeline

  def initialize(name:, pipeline:)
    @name = name
    @pipeline = pipeline
  end

  def serialize(args:, content:)
    serialized_args = serialized_hash(args)
    serialized_pipeline = serialized_array(pipeline)
    "#{MAGIC_MARKER}#{serialized_string(name)}#{serialized_pipeline}#{serialized_args}#{serialized_string(content)}"
  end

  def exec(args:, input_stream:)
    parameterized_pipeline = pipeline.map { |p| p % args }

    # Connect stdin to the input stream only for the first segment of the pipeline
    parameterized_pipeline[0] = [{}, parameterized_pipeline[0], $stdin => input_stream]

    Open3.pipeline_r(*parameterized_pipeline, unsetenv_others: true) do |last_stdout, wait_threads|
      last_stdout.read
    end
  end

  def self.hydrate(stream:)
    return nil if stream.eof

    magic_marker = get_marker(stream)
    raise ArgumentError, 'Magic marker not found' unless magic_marker == MAGIC_MARKER

    name = get_string(stream)
    pipeline = get_pipeline(stream)
    args = get_args(stream)
    content = get_string(stream)

    [new(name: name, pipeline: pipeline), args, content]
  end

  def self.is_operator_content?(content)
    content.start_with?(MAGIC_MARKER)
  end

  private

  def serialized_array(array)
    "#{[array.count].pack('C')}#{array.map { |el| serialized_string(el) }.join}"
  end

  def serialized_hash(hash)
    "#{[hash.count].pack('C')}#{hash.map { |k, v| "#{serialized_string(k.to_s)}#{serialized_string(v)}" }.join}"
  end

  def serialized_string(s)
    s = s.to_s
    len = s.bytes.length
    ([len] + s.bytes).pack("LC#{len}")
  end

  def self.get_marker(stream)
    stream.read(4)
  end
  private_class_method :get_marker

  def self.get_pipeline(stream)
    array_count = stream.read(1).unpack('C')[0]
    array_count.times.map { get_string(stream) }
  end
  private_class_method :get_pipeline

  def self.get_args(stream)
    array_count = stream.read(1).unpack('C')[0]
    array_count.times.reduce({}) do |acc, _|
      key = get_string(stream).to_sym
      value = get_string(stream)
      acc[key] = value
      acc
    end
  end
  private_class_method :get_args

  def self.get_string(stream)
    len = stream.read(4).unpack('L')[0]
    stream.read(len)
  end
  private_class_method :get_string
end
