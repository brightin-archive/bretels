Airbrake.configure do |config|
  config.api_key = ''
  config.host    = ''
  config.port    = 443
  config.secure  = true
  config.rescue_rake_exceptions = true
  ENV.keys.each do |filtered_key|
    config.rake_environment_filters << filtered_key
  end
end
