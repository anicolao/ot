# frozen_string_literal: true

require 'stringio'
require 'tempfile'

module Cmds
  class Splat
    class << self
      def exec(input_stream)
        loop do
          (op, args, content) = Operator.hydrate(stream: input_stream.binmode)
          break unless op

          Tempfile.open do |content_stream|
            # Required because op.exec needs a real file stream, not a StringIO
            content_stream.write(content)
            content_stream.rewind

            result = op.exec(args:, input_stream: content_stream)
            $stdout.binmode.write(
              if Operator.operator_content?(result)
                exec(StringIO.new(result).binmode)
              else
                result
              end
            )
          end
        end
      end
    end
  end
end
