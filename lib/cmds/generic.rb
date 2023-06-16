# frozen_string_literal: true

module Cmds
  class Generic
    class << self
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
  end
end

