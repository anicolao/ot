# frozen_string_literal: true

module Cmds
  class Generic
    class << self
      def exec(name:, content:)
        new(name: name, content: content).send(:output)
      end
    end

    private

    def initialize(name:, content:)
      @name = name
      @content = content
    end
    private_class_method :new

    def output
      op = ::Operator.new(name: @name, content: @content)
      $stdout.binmode.write(op.serialize)
    end
  end
end

