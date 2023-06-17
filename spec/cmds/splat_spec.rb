# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cmds::Splat do
  describe '.exec' do
    let(:content) {
      [
        'hello world 0',
        'hello world 1',
        'hello world 3',
      ]
    }

    it 'properly handles a single non-recursive operation' do
      serialized_input = pexec('bin/base64_e', content[0])
      expect{described_class.exec(StringIO.new(serialized_input))}.to output(content[0]).to_stdout
    end

    it 'properly handles multiple non-recursive operations' do
      serialized_input_0 = pexec('bin/base64_e', content[0])
      serialized_input_1 = pexec('bin/base64_e', content[1])
      serialized_input_2 = pexec('bin/base64_e', content[2])

      expect{described_class.exec(
        StringIO.new("#{serialized_input_0}#{serialized_input_1}#{serialized_input_2}")
      )}.to output(
        "#{content[0]}#{content[1]}#{content[2]}"
      ).to_stdout
    end

    it 'properly handles a single recursive operations' do
      r_serialized_input = pexec('bin/base64_e', pexec('bin/base64_e', content[0]))
      expect{described_class.exec(StringIO.new(r_serialized_input))}.to output(content[0]).to_stdout
    end

    it 'properly handles multiple recursive operations' do
      r_serialized_input_0 = pexec('bin/base64_e', pexec('bin/base64_e', content[0]))
      r_serialized_input_1 = pexec('bin/base64_e', pexec('bin/base64_e', content[1]))
      expect{described_class.exec(
        StringIO.new("#{r_serialized_input_0}#{r_serialized_input_1}")
      )}.to output(
        "#{content[0]}#{content[1]}"
      ).to_stdout
    end
  end
end
