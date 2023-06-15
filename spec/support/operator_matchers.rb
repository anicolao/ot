# frozen_string_literal: true

RSpec::Matchers.define :be_operator do |expected_op_cmd|
  match do |bytestream|
    sio = StringIO.new(bytestream).binmode
    marker = sio.read(4)
    op_cmd = sio.gets(':').chomp(':')
    op_args = sio.gets(':').chomp(':').split(';').reduce({}) do |acc, kv|
      split = kv.split('=')
      acc[split[0].to_sym] = split[1..-1].join
      acc
    end
    op_content_len = sio.gets(':').chomp(':').to_i
    op_content = sio.read(op_content_len)

    @errors = []
    unless (marker == ">><<")
      @errors << "Invalid operator: missing expected marker"
    end
    unless (op_cmd == expected_op_cmd)
      @errors << "Expected operator to be #{expected_op_cmd.inspect} but found #{op_cmd.inspect}"
    end
    unless @args
      @errors << "Expected args value to be tested for explicitly."
    end
    unless (!@args || (op_args == @args))
      @errors << "Expected args to be #{@args.inspect} but found #{op_args.inspect}"
    end
    unless (!@content_len || (op_content_len == @content_len))
      @errors << "Expected content_len to be #{@content_len.inspect} but found #{op_content_len.inspect}"
    end
    unless (!@content || (op_content.unpack("c*") == @content.unpack("c*")))
      @errors << "Expected content to be #{@content.inspect} but found #{op_content.inspect}"
    end
    @errors.empty?
  end

  failure_message do
    <<~MESSAGE
      #{@errors.join("\n")}
    MESSAGE
  end

  def with_no_args
    @args = {}
    self
  end

  def with_args(args)
    @args = args
    self
  end

  def with_no_content
    @content = ''
    @content_len = 0
    self
  end

  def with_content(content, content_len=nil)
    @content = content
    @content_len = content_len || content.bytes.length
    self
  end
end

