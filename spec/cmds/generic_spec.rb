# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cmds::Generic do
  describe '.execs' do
    let(:fwd_args) { {a: 1, b: 2} }
    let(:inv_args) { {x: 7, y: 8} }

    let(:input_stream) { StringIO.new('input stream') }
    let(:fwd_output) { 'forward output' }
    let(:serialized_inv_op) { 'serialized inv op' }

    it 'outputs the serialized version of the inverse operator to $stdout in binmode' do
      fwd_op = spy('fwd op')
      inv_op = spy('inv op')

      expect(fwd_op).to receive(:exec).with(args: fwd_args, input_stream: input_stream).and_return(fwd_output)
      expect(inv_op).to receive(:serialize).with(args: inv_args, content: fwd_output).and_return(serialized_inv_op)

      binmode_stdout = spy('binmode stdout')
      expect($stdout).to receive(:binmode).and_return(binmode_stdout)
      expect(binmode_stdout).to receive(:write).with(serialized_inv_op)

      described_class.exec2(
        fwd_op: fwd_op, fwd_args: fwd_args,
        input_stream: input_stream,
        inv_op: inv_op, inv_args: inv_args
      )
    end
  end

  describe '.exec' do
    let(:op_name) { 'test op' }
    let(:content) { 'test content' }
    let(:serialized_operator) { 'serialized operator' }

    it 'outputs the serialized version of the operator to STDOUT in binmode' do
      op = spy('op')
      expect(::Operator).to receive(:new).with(name: op_name, cmd_adds_nl: false, content: content).and_return(op)
      expect(op).to receive(:serialize).and_return(serialized_operator)

      binmode_stdout = spy('binmode stdout')
      expect($stdout).to receive(:binmode).and_return(binmode_stdout)
      expect(binmode_stdout).to receive(:write).with(serialized_operator)

      described_class.exec(name: op_name, content: content)
    end
  end
end
