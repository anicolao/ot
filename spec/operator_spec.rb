# frozen_string_literal: true

require 'spec_helper'
require 'stringio'
require 'tempfile'
require 'yaml'

RSpec.describe Operator do
  subject(:operator) { described_class.new(name: op_name, pipeline: op_pipeline) }

  let(:op_name) { 'test op name' }
  let(:op_pipeline) { ['wc', "awk '{print $%<test_arg>s}'", 'tr -d "\n"'] }

  def with_file_containing(content)
    Tempfile.open do |f|
      f.write(content)
      f.rewind
      yield f
    end
  end

  describe '#exec' do
    it 'executes the pipeline' do
      with_file_containing('hello world') do |f|
        expect(operator.exec(args: { test_arg: 2 }, input_stream: f)).to eq('2')
      end
    end

    it 'does the correct argument substitutions' do
      with_file_containing('zero lines because of no newline') do |f|
        expect(operator.exec(args: { test_arg: 1 }, input_stream: f)).to eq('0')
      end
      with_file_containing('two words') do |f|
        expect(operator.exec(args: { test_arg: 2 }, input_stream: f)).to eq('2')
      end
    end

    it 'gets the expected output from the pipeline' do
      with_file_containing('hello world') do |f|
        expect(operator.exec(args: { test_arg: 2 }, input_stream: f)).to eq('2')
      end
      with_file_containing('one line with five words') do |f|
        expect(operator.exec(args: { test_arg: 2 }, input_stream: f)).to eq('5')
      end
    end

    xit 'properly handles pipeline errors'
  end

  describe '#serialize' do
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

    let(:args) { { test_arg1: '1', test_arg2: '2' } }
    let(:content) { 'test content' }
    let(:result) { operator.serialize(args:, content:) }

    it 'places a magic marker at the head of the serialized string' do
      expect(result).to start_with(described_class::MAGIC_MARKER)
    end

    it 'places the name in 2nd position (leading 4-byte count representing name length)' do
      expected_substring = serialized_string(op_name)
      expected_position = described_class::MAGIC_MARKER.bytes.length
      expect(result[expected_position..]).to start_with(expected_substring)
    end

    it 'places the pipeline in 3rd position (leading 1-byte count representing number of processes in the pipeline)' do
      expected_substring = serialized_array(op_pipeline)
      expected_position =
        described_class::MAGIC_MARKER.bytes.length +
        serialized_string(op_name).bytes.length
      expect(result[expected_position..]).to start_with(expected_substring)
    end

    it 'places the args in 4th position (leading 1-byte count representing number of arguments)' do
      expected_substring = serialized_hash(args)
      expected_position =
        described_class::MAGIC_MARKER.bytes.length +
        serialized_string(op_name).bytes.length +
        serialized_array(op_pipeline).bytes.length
      expect(result[expected_position..]).to start_with(expected_substring)
    end

    it 'places the content in 5th position (leading 4-byte count representing content length)' do
      expected_substring = serialized_string(content)
      expected_position =
        described_class::MAGIC_MARKER.bytes.length +
        serialized_string(op_name).bytes.length +
        serialized_array(op_pipeline).bytes.length +
        serialized_hash(args).bytes.length
      expect(result[expected_position..]).to start_with(expected_substring)
    end

    context 'when items to be serialized are not strings' do
      let(:op_name) { 1 }
      let(:op_pipeline) { [2, 3] }
      let(:args) { { test_arg: 4 } }
      let(:content) { 5 }

      it 'converts them to strings' do
        expect(result).to eq(
          described_class.new(
            name: op_name.to_s, pipeline: op_pipeline.map(&:to_s)
          ).serialize(
            args: args.transform_values(&:to_s),
            content: content.to_s
          )
        )
      end
    end
  end

  describe '.hydrate' do
    let(:args) { { test_arg1: '1', test_arg2: '2' } }
    let(:content) { 'test content' }
    let(:serialized_input) { operator.serialize(args:, content:) }
    let(:stream) { StringIO.new(serialized_input) }

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
        expect(result[0].name).to eq(op_name)
        expect(result[0].pipeline).to eq(op_pipeline)
      end

      it 'returns the args' do
        result = described_class.hydrate(stream:)
        expect(result[1]).to eq(args)
      end

      it 'returns the content' do
        result = described_class.hydrate(stream:)
        expect(result[2]).to eq(content)
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
