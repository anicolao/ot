# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'store' do
  let(:content) { 'test content' }
  let(:storage_dir) { "#{Dir.home.chomp('/')}/.ot/" }

  it 'produces the correct inverse' do
    sha256sum = pexec('sha256sum -bz', content).split[0]
    expect(pexec('bin/store', content))
      .to be_operator2('fetch')
      .with_pipeline(["cat #{storage_dir}%<sha256sum>s"])
      .with_args(sha256sum:)
      .with_content('')
  end
end
# rubocop:enable RSpec/DescribeClass
