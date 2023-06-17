# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cmds::Generic do
  describe '.exec' do
    let(:fwd_op) { spy('fwd op') }
    let(:inv_op) { spy('inv op') }
    let(:binmode_stdout) { spy('binmode stdout') }

    let(:fwd_args) { {a: 1, b: 2} }
    let(:inv_args) { {x: 7, y: 8} }

    let(:input_stream) { StringIO.new('input stream') }
    let(:fwd_out) { 'forward output' }
    let(:serialized_inv_op) { 'serialized inv op' }

    before :each do
      allow($stdout).to receive(:binmode).and_return(binmode_stdout)
      allow(binmode_stdout).to receive(:write)
    end

    it 'outputs the serialized version of the inverse operator to $stdout in binmode' do
      expect(fwd_op).to receive(:exec).with(args: fwd_args, input_stream: input_stream).and_return(fwd_out)
      expect(inv_op).to receive(:serialize).with(args: inv_args, content: fwd_out).and_return(serialized_inv_op)

      expect($stdout).to receive(:binmode).and_return(binmode_stdout)
      expect(binmode_stdout).to receive(:write).with(serialized_inv_op)

      described_class.exec(
        fwd_op: fwd_op, fwd_args: fwd_args,
        input_stream: input_stream,
        inv_op: inv_op, inv_args: inv_args
      )
    end

    context 'when a block is given to it' do
      let(:revised_output) { 'revised output' }
      let(:revised_inv_args) { {x: 77, y: 88} }

      it "is passed the fwd_op's output and inv_args" do
        allow(fwd_op).to receive(:exec).with(args: fwd_args, input_stream: input_stream).and_return(fwd_out)

        described_class.exec(
          fwd_op: fwd_op, fwd_args: fwd_args,
          input_stream: input_stream,
          inv_op: inv_op, inv_args: inv_args
        ) do |fwd_output:, inv_args:|
          expect(fwd_output).to eq(fwd_out)
          expect(inv_args).to eq(inv_args)
          {}
        end
      end

      it 'uses the returned fwd_output and inv_args when serializing the inverse operation' do
        expect(inv_op).to receive(:serialize).with(args: revised_inv_args, content: revised_output)

        described_class.exec(
          fwd_op: fwd_op, fwd_args: fwd_args,
          input_stream: input_stream,
          inv_op: inv_op, inv_args: inv_args
        ) do |fwd_output:, inv_args:|
          {
            fwd_output: revised_output,
            inv_args: revised_inv_args
          }
        end
      end
    end
  end
end
