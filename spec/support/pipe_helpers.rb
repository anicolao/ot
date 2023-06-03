# frozen_string_literal: true

require 'securerandom'

module PipeHelpers
  def pexec(cmd, content)
    SimpleCov.command_name SecureRandom.uuid
    SimpleCov.start

    cmd = "ruby -r#{__dir__}/.simplecov_spawn #{cmd}" if cmd.start_with?('bin/')

    exit_status = result_out = result_err = nil
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      stdin.write(content)
      stdin.close_write
      exit_status = wait_thread.value
      result_out = stdout.read
      result_err = stderr.read
    end
    if exit_status == 0
      result_out
    else
      [exit_status, result_out, result_err]
    end
  end
end
