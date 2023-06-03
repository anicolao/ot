# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cmds::Splat do
  let(:op1) { Operator.new(cmd: 'cat', content: "test content 1") }
  let(:op2) { Operator.new(cmd: 'cat', content: "test content 2") }
  let(:op3) { Operator.new(cmd: 'base64', content: "test content 3") }
  let(:op4) { Operator.new(cmd: 'dd status=none if=/tmp/%{file}', args: {file: 'abc'}, content: "test content 3") }

  let(:r_op1) { Operator.new(cmd: 'base64', content: op1.serialize) }
  let(:r_op2) { Operator.new(cmd: 'base64', content: op2.serialize) }
  let(:r_op3) { Operator.new(cmd: 'base64', content: op3.serialize) }
  let(:r_op4) { Operator.new(cmd: 'compress', content: r_op1.serialize) }
  let(:r_op5) { Operator.new(cmd: 'compress', content: r_op2.serialize) }
  let(:r_op6) { Operator.new(cmd: 'compress', content: r_op3.serialize) }
  let(:r_op7) {
    Operator.new(cmd: 'base64', content: "#{r_op4.serialize}#{r_op5.serialize}#{r_op6.serialize}")
  }
  let(:r_op8) { Operator.new(cmd: 'compress', content: r_op7.serialize) }

  describe '.exec' do
    it 'properly handles a single non-recursive operation' do
      expect{described_class.exec(op1.serialize)}.to output(op1.content).to_stdout
    end

    xit 'properly handles operations with arguments' do
      expect{described_class.exec(op4.serialize)}.to output(op4.content).to_stdout
    end

    it 'properly handles multiple non-recursive operations' do
      expect{described_class.exec(
        "#{op1.serialize}#{op2.serialize}#{op3.serialize}"
      )}.to output(
        "#{op1.content}#{op2.content}#{op3.content}"
      ).to_stdout
    end

    it 'properly handles a single recursive operations' do
      expect{described_class.exec(r_op1.serialize)}.to output(op1.content).to_stdout
    end

    it 'properly handles multiple recursive operations' do
      expect{described_class.exec(
        "#{r_op4.serialize}#{r_op5.serialize}#{r_op6.serialize}#{r_op8.serialize}"
      )}.to output(
        "#{op1.content}#{op2.content}#{op3.content}#{op1.content}#{op2.content}#{op3.content}"
      ).to_stdout
    end

    it 'properly handles IO streams' do
      expect{described_class.exec(StringIO.new(op1.serialize))}.to output(op1.content).to_stdout
    end

  end
end
