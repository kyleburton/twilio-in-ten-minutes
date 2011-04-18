twilio_config = "#{RAILS_ROOT}/config/twilio.yml"
alt_config = "#{ENV['HOME']}/.ttm.twilio.yml"
if !File.exist?(twilio_config) && File.exist?(alt_config)
  twilio_config = alt_config
end
Rails.logger.info "Using Twilio Conifguration From: #{twilio_config}"

if !File.exist?(twilio_config)
  raise "You must create a #{twilio_config} with the account credentials for your Twilio application.  See the README.textile in the project root for how"
end

TWILIO_ENVIRONMENTS = YAML.load_file(twilio_config)

if !TWILIO_ENVIRONMENTS.has_key?(Rails.env)
  Rails.logger.error "You must create a #{RAILS_ROOT}/config/twilio.yml with the account credentials for your Twilio application.  See the README.textile in the project root for how"
end

TWILIO_CONFIG = TWILIO_ENVIRONMENTS[Rails.env].symbolize_keys


