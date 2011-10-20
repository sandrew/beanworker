#coding: utf-8
require 'timeout'
require 'pry'

module Beanworker
  module Worker
    def perform(num, *tubes)
      num.times do
        Thread.new do
          connection = Beanqueue.connect Beanworker.connection_config
          tubes.each { |tube| connection.watch(tube.gsub('_', '.')) }
          loop do
            get_one_job connection
          end
        end
      end
    end

    def get_one_job(connection)
      job = connection.reserve
      name, args = job.stats['tube'].gsub('.', '_'), job.ybody
      need_fork = args.delete('__fork__')
      work_job(name, job.ttr, args, need_fork.nil? ? @need_fork : need_fork)
      job.delete
    rescue SystemExit
      raise
    rescue
      job.bury rescue nil
    end

    def work_job(name, ttr, args, need_fork=false)
      if need_fork
        Process.wait(Process.fork do
          work_with_timeout(name, ttr, args)
        end)
      else
        work_with_timeout(name, ttr, args)
      end
    end

    def work_with_timeout(name, ttr, args)
      Timeout::timeout(ttr - 1) do
        self.send(name, args)
      end
    end

    def fork_default(val)
      @need_fork = val
    end
  end
end