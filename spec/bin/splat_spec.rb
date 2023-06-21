# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'splat' do
  let(:content) { 'hello world' }

  it 'properly handles a single non-nested operation' do
    fwd_op = instance_spy(Operator, 'fwd_op')
    allow(fwd_op).to receive(:exec).and_return(content)
    serialized_content = capture_stdout do
      Cmds::Generic.exec(
        fwd_op:,
        input_stream: StringIO.new(content),
        inv_op: Operator.new(name: 'cat', pipeline: ['cat'])
      )
    end
    expect(pexec('bin/splat', serialized_content)).to eq(content)
  end

  it 'properly handles multiple non-nested operations' do
    expect(
      pexec('bin/splat',
            pexec('bin/base64_e', content) + pexec('bin/base64_e', content))
    ).to eq(content * 2)
  end

  it 'properly handles a single nested operations' do
    expect(
      pexec('bin/splat',
            pexec('bin/base64_e', pexec('bin/base64_e', content)))
    ).to eq(content)
  end

  it 'properly handles multiple recursive operations' do
    expect(
      pexec('bin/splat',
            pexec('bin/base64_e', pexec('bin/base64_e', content)) +
            pexec('bin/base64_e', pexec('bin/base64_e', content)))
    ).to eq(content * 2)
  end
end
# rubocop:enable RSpec/DescribeClass
