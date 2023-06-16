# frozen_string_literal: true

require 'yaml'

class Operator
  MAGIC_MARKER = '>><<'

  attr_reader :name, :cmd, :args, :content_len, :content

  def initialize(name:, cmd: nil, args: {}, content:)
    @name = name
    @cmd = cmd || name
    @args = args
    @content_len = content.bytes.length
    @content = content
  end

  def serialize
    @serialized ||= begin
      cmd_output = exec
      # Only map arguments that are actually used by the inverse_cmd
      formatted_args = args.map { |k, v| "#{k}=#{v}" if inverse_cmd.include?("%{#{k}}") }.compact.join(';')
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
    nl_adders.include?(name) ? result.chomp("\n") : result
  end

  private

  def inverse_cmd
    commands = self.class.operators_config['commands']
    command = commands.select { |f, _| f.start_with?(name) }
    command = commands.invert.select { |f, _| f.start_with?(name) } if command.empty?

    raise ArgumentError, "Unknown command '#{name}'" if command.empty?

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

      name = from.gets(':').chomp(':')
      args = from.gets(':').chomp(':').split(';').reduce({}) do |acc, kv|
        split = kv.split('=')
        acc[split[0].to_sym] = split[1..-1].join
        acc
      end
      content_len = from.gets(':').chomp(':').to_i
      content = from.read(content_len)

      new(name: name, args: args, content: content)
    end

    def operators_config
      @operators_config ||= YAML.load(File.read(File.join(File.dirname(__FILE__), '../bin/operators.yml')))
    end
  end
end
