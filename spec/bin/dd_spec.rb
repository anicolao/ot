# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'dd status=none' do
  let(:content) { 'test content' }

  it 'produces the correct inverse' do
    sha256sum = pexec('sha256sum -bz', content).split(' ')[0]
    expect(pexec("bin/dd status=none", content))
      .to be_operator("dd status=none if=/tmp/%{file}")
      .with_args(file: sha256sum)
      .with_content('')
  end
end

RSpec.describe 'dd status=none if=/tmp/%{file}' do
  let(:content) { 'test content' }

  it 'produces the correct inverse' do
    sha256sum = pexec('sha256sum -bz', content).split(' ')[0]
    expect(pexec("bin/dd status=none if=/tmp/%{file}", sha256sum))
      .to be_operator("dd status=none")
      .with_content(sha256sum)
  end
end
