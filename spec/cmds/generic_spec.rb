# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cmds::Generic do
  describe '.exec' do
    let(:cmd) { 'test cmd' }
    let(:content) { 'test content' }
    let(:serialized_operator) { 'serialized operator' }

    it 'outputs the serialized version of the operator to STDOUT in binmode' do
      op = spy('op')
      expect(::Operator).to receive(:new).with(cmd: cmd, content: content).and_return(op)
      expect(op).to receive(:serialize).and_return(serialized_operator)

      binmode_stdout = spy('binmode stdout')
      expect($stdout).to receive(:binmode).and_return(binmode_stdout)
      expect(binmode_stdout).to receive(:write).with(serialized_operator)

      described_class.exec(cmd: cmd, content: content)
    end
  end
end
