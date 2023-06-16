# frozen_string_literal: true

module Cmds
  class Generic
    class << self
      def exec(name:, cmd_adds_nl: false, content:)
        new(name: name, cmd_adds_nl: cmd_adds_nl, content: content).send(:output)
      end

      def exec2(
        fwd_op:, fwd_args:, input_stream:,
        inv_op:, inv_args:
      )
        fwd_output = fwd_op.exec(args: fwd_args, input_stream: input_stream)
        $stdout.binmode.write(
          inv_op.serialize(args: inv_args, content: fwd_output)
        )
      end
    end

    private

    def initialize(name:, cmd_adds_nl:, content:)
      @name = name
      @cmd_adds_nl = cmd_adds_nl
      @content = content
    end
    private_class_method :new

    def output
      op = ::Operator.new(name: @name, cmd_adds_nl: @cmd_adds_nl, content: @content)
      $stdout.binmode.write(op.serialize)
    end
  end
end

