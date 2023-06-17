# frozen_string_literal: true

module Cmds
  class Generic
    def self.exec(
      fwd_op:, fwd_args:, input_stream:,
      inv_op:, inv_args:
    )
      fwd_output = fwd_op.exec(args: fwd_args, input_stream: input_stream)

      if block_given?
        return_hash = yield(fwd_output: fwd_output, inv_args: inv_args)
        fwd_output = return_hash[:fwd_output] if return_hash[:fwd_output]
        inv_args = return_hash[:inv_args] if return_hash[:inv_args]
      end

      $stdout.binmode.write(
        inv_op.serialize(args: inv_args, content: fwd_output)
      )
    end
  end
end

