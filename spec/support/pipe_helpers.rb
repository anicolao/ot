# frozen_string_literal: true

require 'securerandom'

module PipeHelpers
  def pexec(cmd, content)
    SimpleCov.command_name SecureRandom.uuid
    SimpleCov.start

    cmd = "ruby -r#{__dir__}/.simplecov_spawn #{cmd}" if cmd.start_with?('bin/')
    IO.popen(cmd, 'r+') do |pipe|
      pipe.write(content)
      pipe.close_write
      pipe.read
    end
  end
end
