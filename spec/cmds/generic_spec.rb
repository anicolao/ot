# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cmds::Generic do
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
