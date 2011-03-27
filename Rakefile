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
