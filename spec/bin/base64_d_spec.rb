# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'base64_d' do
  it 'produces the correct inverse' do
    expect(pexec('bin/base64_d', 'dGVzdCBjb250ZW50'))
      .to be_operator2('base64_e')
      .with_pipeline(['base64', "ruby -e 'print $stdin.binmode.read.chomp(\"\n\")'"])
      .with_no_args
      .with_content('test content')
  end

  it 'produces the correct inverse also when the decoded content contains a trailing newline' do
    expect(pexec('bin/base64_d', 'dGVzdCBjb250ZW50Cg=='))
      .to be_operator2('base64_e')
      .with_pipeline(['base64', "ruby -e 'print $stdin.binmode.read.chomp(\"\n\")'"])
      .with_no_args
      .with_content("test content\n")
  end
end
