# frozen_string_literal: true

require 'stringio'

module Cmds
  class Split
    class Strategy
      class Block
        def initialize(size:)
          @size = size
        end

        def yielder(input_stream:)
          while block=input_stream.read(@size)
            yield block
          end
        end
      end
    end

    class << self
      def exec(input, strategy: Strategy::Block, **params)
        input_stream = input.is_a?(String) ? StringIO.new(input) : input
        strategy.new(**params).yielder(input_stream: input_stream) do |block|
          $stdout.binmode.write(Operator.new(cmd: 'cat', content: block).serialize)
        end
      end
    end

    private_class_method :new
  end
end
