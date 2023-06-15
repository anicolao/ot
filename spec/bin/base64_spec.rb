# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'base64' do
  it 'produces the correct inverse' do
    expect(pexec('bin/base64', 'test content'))
      .to be_operator('base64 -d')
      .with_no_args
      .with_content('dGVzdCBjb250ZW50')
  end

  it 'produces the correct inverse also when the content contains a trailing newline' do
    expect(pexec('bin/base64', "test content\n"))
      .to be_operator('base64 -d')
      .with_no_args
      .with_content('dGVzdCBjb250ZW50Cg==')
  end
end

RSpec.describe 'base64 -d' do
  it 'produces the correct inverse' do
    expect(pexec('bin/base64 -d', 'dGVzdCBjb250ZW50'))
      .to be_operator('base64')
      .with_no_args
      .with_content('test content')
  end

  it 'produces the correct inverse also when the decoded content contains a trailing newline' do
    expect(pexec('bin/base64 -d', 'dGVzdCBjb250ZW50Cg=='))
      .to be_operator('base64')
      .with_no_args
      .with_content("test content\n")
  end
end
