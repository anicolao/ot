# frozen_string_literal: true

RSpec::Matchers.define :be_operator do |expected_op_name|
  match do |bytestream|
    @errors = []

    unless @args
      @errors << 'Expected args value to be tested for explicitly.'
      return false
    end

    sio = StringIO.new(bytestream).binmode
    marker = get_marker(sio)
    unless marker == '>><<'
      @errors << 'Invalid operator: missing expected marker'
      return false
    end

    op_name = get_string(sio)
    unless op_name == expected_op_name
      @errors << "Expected operator to be #{expected_op_name} but found #{op_name}"
      return false
    end

    op_pipeline = get_pipeline(sio)
    unless op_pipeline == @pipeline
      @errors << "Expected pipeline to be #{@pipeline.inspect} but found #{op_pipeline.inspect}"
      return false
    end

    op_args = get_args(sio)
    unless !@args || (op_args == @args)
      @errors << "Expected args to be #{@args.inspect} but found #{op_args.inspect}"
      return false
    end

    op_content = get_string(sio)
    unless !@content || (op_content.unpack('c*') == @content.unpack('c*'))
      @errors << "Expected content to be #{@content.inspect} but found #{op_content.inspect}"
      return false
    end

    true
  end

  failure_message do
    @errors.join("\n")
  end

  def get_marker(stream)
    stream.read(4)
  end

  def get_pipeline(stream)
    array_count = stream.read(1).unpack1('C')
    array_count.times.map { get_string(stream) }
  end

  def get_args(stream)
    array_count = stream.read(1).unpack1('C')
    array_count.times.each_with_object({}) do |_, acc|
      key = get_string(stream).to_sym
      value = get_string(stream)
      acc[key] = value
    end
  end

  def get_string(stream)
    len = stream.read(4).unpack1('L')
    stream.read(len)
  end

  def with_pipeline(pipeline)
    @pipeline = pipeline
    self
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

  def with_content(content, content_len = nil)
    @content = content
    @content_len = content_len || content.bytes.length
    self
  end
end
