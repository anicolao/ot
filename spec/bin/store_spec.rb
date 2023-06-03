# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'store' do
  let(:content) { 'test content' }
  let(:storage_dir) { "#{Dir.home.chomp('/')}/.ot/" }

  it 'produces the correct inverse' do
    sha256sum = pexec('sha256sum -bz', content).split[0]
    expect(pexec('bin/store', content))
      .to be_operator('fetch')
      .with_pipeline(["cat #{storage_dir}%<sha256sum>s"])
      .with_args(sha256sum:)
      .with_content('')
  end

  it 'stores the content in ~/.ot/ using the sha256sum as the filename' do
    sha256sum = pexec('sha256sum -bz', content).split[0]
    pexec('bin/store', content)
    expect(`cat #{storage_dir}/#{sha256sum}`).to eq(content)
  end

  context 'when the file already exists' do
    it 'is not overwritten' do
      sha256sum = pexec('sha256sum -bz', content).split[0]

      filename = "#{storage_dir}#{sha256sum}"
      FileUtils.mkdir_p(File.dirname(filename))
      FileUtils.touch(filename)
      original_mtime = File.mtime(filename)

      pexec('bin/store', content)
      expect(File.mtime(filename)).to eq(original_mtime)
    end
  end
end
# rubocop:enable RSpec/DescribeClass
