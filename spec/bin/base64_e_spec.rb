# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'base64_e' do
  it 'produces the correct inverse' do
    expect(pexec('bin/base64_e', 'test content'))
      .to be_operator2('base64_d')
      .with_pipeline(['base64 -d'])
      .with_no_args
      .with_content('dGVzdCBjb250ZW50')
  end

  it 'produces the correct inverse also when the content contains a trailing newline' do
    expect(pexec('bin/base64_e', "test content\n"))
      .to be_operator2('base64_d')
      .with_pipeline(['base64 -d'])
      .with_no_args
      .with_content('dGVzdCBjb250ZW50Cg==')
  end
end
