# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'splat' do
  let(:op1) { Operator.new(name: 'cat', content: "test content 1") }
  let(:op2) { Operator.new(name: 'cat', content: "test content 2") }
  let(:op3) { Operator.new(name: 'base64', content: "test content 3") }

  let(:r_op1) { Operator.new(name: 'base64', content: op1.serialize) }
  let(:r_op2) { Operator.new(name: 'base64', content: op2.serialize) }
  let(:r_op3) { Operator.new(name: 'base64', content: op3.serialize) }
  let(:r_op4) { Operator.new(name: 'compress', content: r_op1.serialize) }
  let(:r_op5) { Operator.new(name: 'compress', content: r_op2.serialize) }
  let(:r_op6) { Operator.new(name: 'compress', content: r_op3.serialize) }
  let(:r_op7) {
    Operator.new(name: 'base64', content: "#{r_op4.serialize}#{r_op5.serialize}#{r_op6.serialize}")
  }
  let(:r_op8) { Operator.new(name: 'compress', content: r_op7.serialize) }

  it 'properly handles a single non-recursive operation' do
    expect(pexec('bin/splat', op1.serialize)).to eq(op1.content)
  end

  it 'properly handles multiple non-recursive operations' do
    expect(pexec('bin/splat', "#{op1.serialize}#{op2.serialize}#{op3.serialize}"))
      .to eq("#{op1.content}#{op2.content}#{op3.content}")
  end

  it 'properly handles a single recursive operations' do
    expect(pexec('bin/splat', r_op1.serialize)).to eq("#{op1.content}")
  end

  it 'properly handles multiple recursive operations' do
    expect(pexec('bin/splat', "#{r_op4.serialize}#{r_op5.serialize}#{r_op6.serialize}#{r_op8.serialize}"))
      .to eq("#{op1.content}#{op2.content}#{op3.content}#{op1.content}#{op2.content}#{op3.content}")
  end
end
