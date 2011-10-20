require 'test/unit'
require File.dirname(__FILE__) + '/../lib/beanworker'
require File.dirname(__FILE__) + '/classes/some_worker'

class TestBeanworker < Test::Unit::TestCase

  def setup
    SomeWorker.fork_default nil
  end
  
  def test_truth
    Beanworker.run daemonize: false, connection_file: './test/configs/one.yml', jobs_file: './test/classes/some_worker', no_wait: true
    assert_equal 'localhost:11300', Beanworker.connection_config

    Beanworker.run daemonize: false, connection_host: 'localhost:11300', jobs_file: './test/classes/some_worker', no_wait: true
    assert_equal 'localhost:11300', Beanworker.connection_config
  end

  def test_fork_default
    assert_nil SomeWorker.instance_eval { @need_fork }, '@need_fork should not be set'

    SomeWorker.fork_default true

    assert SomeWorker.instance_eval { @need_fork }, '@need_fork should be set'
  end

  def test_work_with_timeout
    assert_nothing_raised do
      SomeWorker.work_with_timeout 'do_something_and_sleep', 3, time: 1, num: 1
    end

    assert_raise Timeout::Error do
      SomeWorker.work_with_timeout 'do_something_and_sleep', 3, time: 4, num: 2
    end
  end

  def test_work_job
    assert_nothing_raised do
      SomeWorker.work_job 'do_something_and_sleep', 3, { time: 1, num: 3 }
    end

    assert_nothing_raised do
      SomeWorker.work_job 'do_something_and_sleep', 3, { time: 1, num: 4 }, true
    end
  end

  def test_get_one_job
    c1 = Beanqueue.connect 'localhost:11300'
    c1.watch 'do.something.and.sleep'
    Beanqueue.connect 'localhost:11300'
    Beanqueue.push 'do.something.and.sleep', time: 1, num: 5
    SomeWorker.get_one_job c1
  end

  def test_perform
    Beanworker.connection_config = 'localhost:11300'
    SomeWorker.perform 1, 'do.something.and.sleep'
    Beanqueue.connect 'localhost:11300'
    Beanqueue.push 'do.something.and.sleep', time: 1, num: 6
    sleep(3)
  end
end