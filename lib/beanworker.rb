#coding: utf-8
require 'daemons'
require 'beanqueue'
require 'logger'
require File.dirname(__FILE__) + '/beanworker/worker'

module Beanworker
  VERSION = '0.0.4'

  class << self
    attr_accessor :connection_config

    def run(opts={})
      self.connection_config = opts[:connection_host] || Beanqueue.get_params(opts[:connection_file])
      if opts[:daemonize]
        Daemons.run_proc 'beanworker', ARGV: ['start'], monitor: opts[:monitor], dir: opts[:pid_dir] do
          run_loop(opts)
        end
      else
        run_loop(opts)
      end
    end

    def run_loop(opts={})
      require opts[:jobs_file]
      loop { gets } unless opts[:no_wait]
    end
  end
end