# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'compress' do
  it 'produces the correct inverse' do
    expect(pexec('bin/compress', 'test content'))
      .to be_operator('uncompress')
      .with_pipeline(['uncompress'])
      .with_no_args
      .with_content("\x1F\x9D\x90t\xCA\xCC\xA1\x03b\xCC\e7\x01\x11\x02")
  end
end
# rubocop:enable RSpec/DescribeClass
