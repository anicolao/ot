# frozen_string_literal: true

module Cmds
  class Generic
    MAGIC_MARKER = '>><<'

    def self.exec(fwd_op:, fwd_args:, input_stream:, inv_op:, inv_args: {})
      output = fwd_op.exec(args: fwd_args, input_stream:)

      to_serialize = {
        name: inv_op.name, pipeline: inv_op.pipeline,
        args: inv_args, content: output
      }
      to_serialize.merge!(yield output) if block_given?

      $stdout.binmode.write(
        serialize(**to_serialize)
      )
    end

    def self.hydrate(stream:)
      return nil if stream.eof

      magic_marker = get_marker(stream)
      raise ArgumentError, 'Magic marker not found' unless magic_marker == MAGIC_MARKER

      name = get_string(stream)
      pipeline = get_pipeline(stream)
      args = get_args(stream)
      content = get_string(stream)

      [Operator.new(name:, pipeline:), args, content]
    end

    def self.operator_content?(content)
      content.start_with?(MAGIC_MARKER)
    end

    def self.serialize(name:, pipeline:, args:, content:)
      serialized_args = serialized_hash(args)
      serialized_pipeline = serialized_array(pipeline)
      "#{MAGIC_MARKER}#{serialized_string(name)}#{serialized_pipeline}#{serialized_args}#{serialized_string(content)}"
    end
    private_class_method :serialize

    def self.serialized_array(array)
      "#{[array.count].pack('C')}#{array.map { |el| serialized_string(el) }.join}"
    end
    private_class_method :serialized_array

    def self.serialized_hash(hash)
      "#{[hash.count].pack('C')}#{hash.map { |k, v| "#{serialized_string(k.to_s)}#{serialized_string(v)}" }.join}"
    end
    private_class_method :serialized_hash

    def self.serialized_string(str)
      str = str.to_s
      len = str.bytes.length
      ([len] + str.bytes).pack("LC#{len}")
    end
    private_class_method :serialized_string

    def self.get_marker(stream)
      stream.read(4)
    end
    private_class_method :get_marker

    def self.get_pipeline(stream)
      array_count = stream.read(1).unpack1('C')
      array_count.times.map { get_string(stream) }
    end
    private_class_method :get_pipeline

    def self.get_args(stream)
      array_count = stream.read(1).unpack1('C')
      array_count.times.each_with_object({}) do |_, acc|
        key = get_string(stream).to_sym
        value = get_string(stream)
        acc[key] = value
      end
    end
    private_class_method :get_args

    def self.get_string(stream)
      len = stream.read(4).unpack1('L')
      stream.read(len)
    end
    private_class_method :get_string
  end
end
