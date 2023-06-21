# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cmds::Split do
  describe '.exec' do
    let(:content) { 'hello world' }
    let(:test_strategy_class) do
      Class.new do
        def initialize(p1:, p2:)
        end

        def split(input_stream:)
        end
      end
    end

    around :each do |spec|
      Tempfile.open do |f|
        f.write(content)
        f.rewind
        @input_stream = f
        spec.run
      end
    end

    it 'defaults to the FixedBlockSize strategy' do
      expect_any_instance_of(Cmds::Split::Strategy::FixedBlockSize).to receive(:split).with(input_stream: @input_stream)
      described_class.exec(input_stream: @input_stream, size: 5)
    end

    it "passes params other than input_stream and strategy to the stategy's constructor" do
      p1 = 1
      p2 = 2
      strategy = spy(test_strategy_class)
      expect(strategy).to receive(:new).with(p1:, p2:)
      described_class.exec(input_stream: @input_stream, strategy:, p1:, p2:)
    end

    it "invokes the strategy's `split` method, passing it the input_stream" do
      expect_any_instance_of(test_strategy_class).to receive(:split).with(input_stream: @input_stream)
      described_class.exec(input_stream: @input_stream, strategy: test_strategy_class, p1: 1, p2: 2)
    end

    it "outputs the result of Store operations for each section of content" do
      size = 5
      expected_output = capture_stdout do
        @input_stream.each(size) do |block|
          Tempfile.open do |f|
            f.write(block)
            f.rewind
            Cmds::Store.exec(input_stream: f)
          end
        end
      end
      @input_stream.rewind
      expect{
        described_class.exec(input_stream: @input_stream, strategy: Cmds::Split::Strategy::FixedBlockSize, size:)
      }.to output(expected_output).to_stdout
    end
  end
end
