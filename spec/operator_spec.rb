# frozen_string_literal: true

require 'spec_helper'
require 'stringio'
require 'tempfile'
require 'yaml'

RSpec.describe Operator do
  subject(:operator) { described_class.new(name: op_name, pipeline: op_pipeline) }

  let(:op_name) { 'test op name' }
  let(:op_pipeline) { ['wc', "awk '{printf \"%%s\", $%<test_arg>s}'"] }

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
end
