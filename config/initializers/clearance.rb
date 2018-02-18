Clearance.configure do |config|
  config.allow_sign_up = false
  config.routes = false
  config.mailer_sender = 'reply@example.com'
  config.rotate_csrf_on_sign_in = true
  config.cookie_expiration = lambda { |cookies| 8.hours.from_now.utc }
end
