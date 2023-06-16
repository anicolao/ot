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

  private

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

  #def inverse_cmd
  #  commands = self.class.operators_config['commands']
  #  command = commands.select { |f, _| f.start_with?(name) }
  #  command = commands.invert.select { |f, _| f.start_with?(name) } if command.empty?
#
#    raise ArgumentError, "Unknown command '#{name}'" if command.empty?
#
#    command.values[0]
#  end

#  class << self
#    def is_operator_content?(content)
#      content.start_with?('>><<')
#    end
#
#    def deserialize(from: STDIN)
#      return nil if from.eof
#
#      magic_marker = from.read(4)
#      raise ArgumentError, 'Magic marker not found' unless magic_marker == MAGIC_MARKER
#
#      name = from.gets(':').chomp(':')
#      args = from.gets(':').chomp(':').split(';').reduce({}) do |acc, kv|
#        split = kv.split('=')
#        acc[split[0].to_sym] = split[1..-1].join
#        acc
#      end
#      content_len = from.gets(':').chomp(':').to_i
#      content = from.read(content_len)
#
#      new(name: name, args: args, content: content)
#    end

    #def operators_config
    #  @operators_config ||= YAML.load(File.read(File.join(File.dirname(__FILE__), '../bin/operators.yml')))
    #end
#  end
end
