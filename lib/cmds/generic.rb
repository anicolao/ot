# frozen_string_literal: true

module Cmds
  class Generic
    class << self
      def exec(name:, cmd_adds_nl: false, content:)
        new(name: name, cmd_adds_nl: cmd_adds_nl, content: content).send(:output)
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

