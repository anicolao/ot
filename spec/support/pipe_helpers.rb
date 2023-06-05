# frozen_string_literal: true

module PipeHelpers
  def pexec(cmd, content)
    IO.popen(cmd, 'r+') do |pipe|
      pipe.write(content)
      pipe.close_write
      pipe.read
    end
  end
end
