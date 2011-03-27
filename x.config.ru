WEBSITE_SUBDIR = 'twilio-app'
require "#{WEBSITE_SUBDIR}/config/environment"
use Rails::Rack::LogTailer
use Rails::Rack::Static
run ActionController::Dispatcher.new
