# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'split' do
  it 'execs the Split command with $stdin in binmode' do
    expect(Cmds::Split).to receive(:exec).with(
      input_stream: $stdin.binmode,
      strategy: Cmds::Split::Strategy::FixedBlockSize,
      size: 5
    )
    load('bin/split')
  end
end
# rubocop:enable RSpec/DescribeClass
