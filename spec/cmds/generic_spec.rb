# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cmds::Generic do
  let(:fwd_op) { instance_spy(Operator, 'fwd_op') }
  let(:fwd_args) { instance_spy(Hash) }

  let(:inv_op_name) { 'inv op' }
  let(:inv_op_pipeline) { ['a', 'b'] }
  let(:inv_op) { Operator.new(name: inv_op_name, pipeline: inv_op_pipeline) }
  let(:inv_args) { { x: 'x', y: 'y' } }

  let(:input_stream) { StringIO.new('input data') }
  let(:fwd_out) { 'forward output' }

  before do
    allow(fwd_op).to receive(:exec).with(args: fwd_args, input_stream:).and_return(fwd_out)
  end

  describe '.exec' do
    it 'outputs the serialized version of the inverse operator to $stdout in binmode' do
      output = capture_stdout {
        described_class.exec(fwd_op:, fwd_args:, input_stream:, inv_op:, inv_args:)
      }
      expect(output).to be_operator(inv_op.name)
        .with_pipeline(inv_op.pipeline)
        .with_args(inv_args)
        .with_content(fwd_out)
    end

    context 'the serialized output (for the inverse operation)' do
      def serialized_array(array)
        "#{[array.count].pack('C')}#{array.map { |el| serialized_string(el) }.join}"
      end

      def serialized_hash(hash)
        "#{[hash.count].pack('C')}#{hash.map { |k, v| "#{serialized_string(k.to_s)}#{serialized_string(v)}" }.join}"
      end

      def serialized_string(str)
        str = str.to_s
        len = str.bytes.length
        ([len] + str.bytes).pack("LC#{len}")
      end

      subject(:output) {
        capture_stdout {
          described_class.exec(fwd_op:, fwd_args:, input_stream:, inv_op:, inv_args:)
        }
      }

      it 'starts with a magic marker' do
        expect(output).to start_with(described_class::MAGIC_MARKER)
      end

      it 'has the name in 2nd position (leading 4-byte count representing name length)' do
        expected_substring = serialized_string(inv_op.name)
        expected_position = described_class::MAGIC_MARKER.bytes.length
        expect(output[expected_position..]).to start_with(expected_substring)
      end

      it 'has the pipeline in 3rd position (leading 1-byte count representing number of processes in the pipeline)' do
        expected_substring = serialized_array(inv_op.pipeline)
        expected_position =
          described_class::MAGIC_MARKER.bytes.length +
          serialized_string(inv_op.name).bytes.length
        expect(output[expected_position..]).to start_with(expected_substring)
      end

      it 'has the args in 4th position (leading 1-byte count representing number of arguments)' do
        expected_substring = serialized_hash(inv_args)
        expected_position =
          described_class::MAGIC_MARKER.bytes.length +
          serialized_string(inv_op.name).bytes.length +
          serialized_array(inv_op.pipeline).bytes.length
        expect(output[expected_position..]).to start_with(expected_substring)
      end

      it 'has the content in 5th position (leading 4-byte count representing content length)' do
        expected_substring = serialized_string(fwd_out)
        expected_position =
          described_class::MAGIC_MARKER.bytes.length +
          serialized_string(inv_op.name).bytes.length +
          serialized_array(inv_op.pipeline).bytes.length +
          serialized_hash(inv_args).bytes.length
        expect(output[expected_position..]).to start_with(expected_substring)
      end

      context 'for not string items' do
        let(:inv_op_name) { 1 }
        let(:inv_op_pipeline) { [2, 3] }
        let(:inv_args) { { test_arg: 4 } }

        it 'converts them to strings' do
          expect(output).to eq(
            capture_stdout {
              described_class.exec(
                fwd_op:, fwd_args:, input_stream:,
                inv_op: Operator.new(name: inv_op_name.to_s, pipeline: inv_op_pipeline.map { |x| x.to_s }),
                inv_args: inv_args.transform_values { |v| v.to_s }
              )
            }
          )
        end
      end
    end
  end

  describe '.hydrate' do
    let(:stream) do
      StringIO.new(
        capture_stdout {
          described_class.exec(fwd_op:, fwd_args:, input_stream:, inv_op:, inv_args:)
        }
      )
    end


    it 'returns nil if the stream is at EOF' do
      stream = instance_spy(IO, 'stream')
      allow(stream).to receive(:eof).and_return(true)
      expect(described_class.hydrate(stream:)).to be_nil
    end

    context 'when properly hydrated' do
      it 'returns a 3-element array (operator, args, content)' do
        result = described_class.hydrate(stream:)
        expect(result.size).to eq(3)
      end

      it 'returns the correct operator' do
        result = described_class.hydrate(stream:)
        expect(result[0].name).to eq(inv_op.name)
        expect(result[0].pipeline).to eq(inv_op.pipeline)
      end

      it 'returns the args' do
        result = described_class.hydrate(stream:)
        expect(result[1]).to eq(inv_args)
      end

      it 'returns the content' do
        result = described_class.hydrate(stream:)
        expect(result[2]).to eq(fwd_out)
      end
    end

    context 'when the magic marker is missing' do
      let(:stream) { StringIO.new('garbage') }

      it 'raises an error' do
        expect { described_class.hydrate(stream:) }.to raise_error(ArgumentError, 'Magic marker not found')
      end
    end
  end
end
