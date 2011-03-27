# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

Dir.glob("lib/tasks/*.rb").each do |f|
  require f
end

namespace :twilio_in_ten_minutes do
  namespace :gems do
    desc "Build and install local gems"
    task :build do
      %w[newflow twml].each do |proj|
        system "cd #{proj}; gem build #{proj}.gemspec; gem install #{proj}-*.gem"
      end
    end
  end
end
