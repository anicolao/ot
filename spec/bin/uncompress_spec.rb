# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'uncompress' do
  it 'produces the correct inverse' do
    expect(pexec('bin/uncompress', "\x1F\x9D\x90t\xCA\xCC\xA1\x03b\xCC\e7\x01\x11\x02"))
      .to be_operator('compress')
      .with_content("test content")
  end
end
