#coding: utf-8
require 'timeout'
require 'time'
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

    def schedule(name, frequency, opts={}, *args)
      at = make_first_schedule(frequency, opts[:at])
      timeout_secs = [opts[:timeout] || frequency, frequency-5].min
      Thread.new do
        loop do
          sleep(at - Time.now)
          Timeout.timeout timeout_secs do
            self.send(name, *args)
          end
          at += frequency
        end
      end
    end

    private

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

    def make_first_schedule(frequency, at)
      if at && (frequency % (24*3600) == 0)
        t = Time.parse at
        t > Time.now ? t : (t + 24*3600)
      else
        Time.now + frequency
      end
    end
  end
end