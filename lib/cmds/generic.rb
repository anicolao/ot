# frozen_string_literal: true

module Cmds
  class Generic
    class << self
      def exec(cmd:, content:)
        new(cmd: cmd, content: content).send(:output)
      end
    end

    private

    def initialize(cmd:, content:)
      @cmd = cmd
      @content = content
    end
    private_class_method :new

    def output
      op = ::Operator.new(cmd: @cmd, content: @content)
      $stdout.binmode.write(op.serialize)
    end
  end
end

