# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'cat' do
  it 'produces the correct inverse' do
    expect(pexec('bin/cat', 'test content'))
      .to be_operator('cat')
      .with_no_args
      .with_content('test content')
  end
end
