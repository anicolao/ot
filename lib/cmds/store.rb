# frozen_string_literal: true

module Cmds
  class Store < Generic
    STORAGE_DIR = "#{ENV['HOME'].chomp('/')}/.ot/"

    def self.exec(input_stream:)
      temp_filename = "#{STORAGE_DIR}temp-#{Process.pid}"
      store_op = Operator.new(name: 'store', pipeline: ["tee #{temp_filename}", 'sha256sum -bz', "awk '{printf $1}'", 'tr -d "\n"'])
      fetch_op = Operator.new(name: 'fetch', pipeline: ["cat #{STORAGE_DIR}%{sha256sum}"])
      super(
        fwd_op: store_op,
        fwd_args: {},
        input_stream: input_stream,
        inv_op: fetch_op,
        inv_args: {}
      ) do |fwd_output:, inv_args:|
        sha256sum = fwd_output
        dest_filename = "#{STORAGE_DIR}#{sha256sum}"
        if File.exist?(dest_filename)
          FileUtils.rm(temp_filename)
        else
          FileUtils.mv(temp_filename, dest_filename)
        end
        {
          fwd_output: '',
          inv_args: inv_args.merge(sha256sum: sha256sum)
        }
      end
    end
  end
end
