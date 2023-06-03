# frozen_string_literal: true

require 'yaml'

class Operator
  MAGIC_MARKER = '>><<'

  attr_reader :cmd, :args, :content_len, :content

  def initialize(cmd:, args: {}, content:)
    @cmd = cmd
    @args = args
    @content_len = content.bytes.length
    @content = content
  end

  def serialize
    @serialized ||= begin
      cmd_output = exec
      formatted_args = args.map { |k, v| "#{k}=#{v}" }.join(';')
      "#{MAGIC_MARKER}#{inverse_cmd}:#{formatted_args}:#{cmd_output.bytes.length}:#{cmd_output}"
    end
  end

  def exec
    parameterized_cmd = cmd % args
    result = IO.popen(parameterized_cmd, 'r+') do |pipe|
      pipe.write(content)
      pipe.close_write
      pipe.read
    end
    nl_adders.include?(cmd) ? result.chomp("\n") : result
  end

  private

  def inverse_cmd
    commands = self.class.operators_config['commands']
    command = commands.select { |f, _| f.start_with?(cmd) }
    command = commands.invert.select { |f, _| f.start_with?(cmd) } if command.empty?

    raise ArgumentError, "Unknown command '#{cmd}'" if command.empty?

    command.values[0]
  end

  def nl_adders
    self.class.operators_config['nl_adders']
  end

  class << self
    def is_operator_content?(content)
      content.start_with?('>><<')
    end

    def deserialize(from: STDIN)
      return nil if from.eof

      magic_marker = from.read(4)
      raise ArgumentError, 'Magic marker not found' unless magic_marker == MAGIC_MARKER

      cmd = from.gets(':').chomp(':')
      args = from.gets(':').chomp(':').split(';').reduce({}) do |acc, kv|
        split = kv.split('=')
        acc[split[0].to_sym] = split[1..-1].join
        acc
      end
      content_len = from.gets(':').chomp(':').to_i
      content = from.read(content_len)

      new(cmd: cmd, args: args, content: content)
    end

    def operators_config
      @operators_config ||= YAML.load(File.read(File.join(File.dirname(__FILE__), '../bin/operators.yml')))
    end
  end
end
