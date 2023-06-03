# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'cat' do
  it 'produces the correct inverse' do
    expect(pexec('bin/cat', 'test content'))
      .to be_operator('cat')
      .with_pipeline(['cat'])
      .with_no_args
      .with_content('test content')
  end

  it 'produces the correct inverse also when the content contains a trailing newline' do
    expect(pexec('bin/cat', "test content\n"))
      .to be_operator('cat')
      .with_pipeline(['cat'])
      .with_no_args
      .with_content("test content\n")
  end
end
# rubocop:enable RSpec/DescribeClass
