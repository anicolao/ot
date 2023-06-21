# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'split' do
  let(:content) { 'hello world' }

  it "outputs the result of 'cat' operations for each section of content" do
    content_stream = StringIO.new(pexec('bin/split -b 5', content))
    expect(content_stream).to be_operator('cat')
      .with_pipeline(['cat'])
      .with_no_args
      .with_content('hello')
      .allowing_additional_content
    expect(content_stream).to be_operator('cat')
      .with_pipeline(['cat'])
      .with_no_args
      .with_content(' worl')
      .allowing_additional_content
    expect(content_stream).to be_operator('cat')
      .with_pipeline(['cat'])
      .with_no_args
      .with_content('d')
  end
end
# rubocop:enable RSpec/DescribeClass
