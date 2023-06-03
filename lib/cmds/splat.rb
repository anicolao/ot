# frozen_string_literal: true

require 'stringio'

module Cmds
  class Splat
    class << self
      def exec(input)
        input_stream = input.is_a?(String) ? StringIO.new(input) : input
        new.send(:output, input_stream: input_stream)
      end
    end

    private

    def output(input_stream:)
      while op=Operator.deserialize(from: input_stream) do
        result = op.exec
        $stdout.binmode.write(
          if Operator.is_operator_content?(result)
            output(input_stream: StringIO.new(result).binmode)
          else
            result
          end
        )
      end
    end

    private_class_method :new
  end
end
