# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cmds::Splat do
  describe '.exec' do
    let(:content) do
      [
        'hello world 0',
        'hello world 1',
        'hello world 3'
      ]
    end

    it 'properly handles a single non-recursive operation' do
      serialized_input = pexec('bin/base64_e', content[0])
      expect { described_class.exec(StringIO.new(serialized_input)) }.to output(content[0]).to_stdout
    end

    it 'properly handles multiple non-recursive operations' do
      serialized_input0 = pexec('bin/base64_e', content[0])
      serialized_input1 = pexec('bin/base64_e', content[1])
      serialized_input2 = pexec('bin/base64_e', content[2])

      expect do
        described_class.exec(
          StringIO.new("#{serialized_input0}#{serialized_input1}#{serialized_input2}")
        )
      end.to output(
        "#{content[0]}#{content[1]}#{content[2]}"
      ).to_stdout
    end

    it 'properly handles a single recursive operations' do
      r_serialized_input = pexec('bin/base64_e', pexec('bin/base64_e', content[0]))
      expect { described_class.exec(StringIO.new(r_serialized_input)) }.to output(content[0]).to_stdout
    end

    it 'properly handles multiple recursive operations' do
      r_serialized_input0 = pexec('bin/base64_e', pexec('bin/base64_e', content[0]))
      r_serialized_input1 = pexec('bin/base64_e', pexec('bin/base64_e', content[1]))
      expect do
        described_class.exec(
          StringIO.new("#{r_serialized_input0}#{r_serialized_input1}")
        )
      end.to output(
        "#{content[0]}#{content[1]}"
      ).to_stdout
    end
  end
end
