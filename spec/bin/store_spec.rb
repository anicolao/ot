#_dup frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'store' do
  let(:content) { 'test content' }

  it 'produces the correct inverse' do
    sha256sum = pexec('sha256sum -bz', content).split(' ')[0]
    expect(pexec('bin/store', content))
      .to be_operator('fetch %{sha256sum}')
      .with_args(sha256sum: sha256sum)
      .with_content('')
  end
end
