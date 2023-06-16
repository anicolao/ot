#_dup frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'fetch' do
  let(:content) { 'test content' }

  it 'produces the correct inverse' do
    sha256sum = pexec('sha256sum -bz', content).split(' ')[0]
    expect(pexec("bin/fetch #{sha256sum}", ''))
      .to be_operator('store')
      .with_no_args
      .with_content(content)
  end
end
