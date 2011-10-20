require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/beanworker'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'beanworker' do
  self.developer 'Andrew Shaydurov', 'gearhead@it-primorye.ru'
  self.rubyforge_name     = self.name 
  self.extra_deps         = [['beanstalk-client','>= 0'], ['beanqueue', '>= 0.1.0']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
