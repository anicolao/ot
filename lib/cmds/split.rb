# frozen_string_literal: true

module Cmds
  class Split
    class Strategy
      class FixedBlockSize
        def initialize(size:)
          @size = size
        end

        def split(input_stream:, &block)
          splitter = Operator.new(name: 'block_splitter', pipeline: ["split -b #{@size} -d - \"#{file_prefix}\""])
          splitter.exec(args: {}, input_stream:)
          Dir.glob("#{file_prefix}*").each do |filename|
            File.open(filename, &block)
            File.unlink(filename)
          end
        end

        private

        def file_prefix
          "/tmp/split.#{Process.pid}."
        end
      end
    end

    def self.exec(input_stream:, strategy: Strategy::FixedBlockSize, **params)
      strategy.new(**params).split(input_stream:) do |partial_input_stream|
        Cmds::Store.exec(input_stream: partial_input_stream)
      end
    end

    private_class_method :new
  end
end
