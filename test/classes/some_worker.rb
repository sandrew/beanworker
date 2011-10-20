 class SomeWorker
   extend Beanworker::Worker

   class << self
     def do_something_and_sleep(args)
       puts "start #{args[:num]}"
       sleep args[:time]
       puts "finish #{args[:num]}"
     end
   end
 end