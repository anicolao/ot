# frozen_string_literal: true

module Cmds
  class Store < Generic
    def self.exec(input_stream:)
      temp_filename = "#{storage_dir}temp-#{Process.pid}"
      store_op = Operator.new(name: 'store',
                              pipeline: ["tee #{temp_filename}", 'sha256sum -bz',
                                         "awk '{printf $1}'", 'tr -d "\n"'])
      fetch_op = Operator.new(name: 'fetch', pipeline: ["cat #{storage_dir}%<sha256sum>s"])
      super(
        fwd_op: store_op, fwd_args: {}, input_stream: input_stream, inv_op: fetch_op
      ) do |sha256sum|
        dest_filename = "#{storage_dir}#{sha256sum}"
        if File.exist?(dest_filename)
          FileUtils.rm(temp_filename)
        else
          FileUtils.mv(temp_filename, dest_filename)
        end

        { name: fetch_op.name, pipeline: fetch_op.pipeline, args: {sha256sum: sha256sum}, content: '' }
      end
    end

    def self.storage_dir
      @storage_dir ||= begin
        "#{Dir.home.chomp('/')}/.ot/".freeze.tap do |dir|
          FileUtils.mkdir_p(dir)
        end
      end
    end
  end
end
