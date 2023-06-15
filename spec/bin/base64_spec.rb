# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'base64' do
  it 'produces the correct inverse' do
    expect(pexec('bin/base64', 'test content'))
      .to be_operator('base64 -d')
      .with_no_args
      .with_content('dGVzdCBjb250ZW50')
  end
end

RSpec.describe 'base64 -d' do
  it 'produces the correct inverse' do
    expect(pexec('bin/base64 -d', 'dGVzdCBjb250ZW50'))
      .to be_operator('base64')
      .with_no_args
      .with_content('test content')
  end
end
