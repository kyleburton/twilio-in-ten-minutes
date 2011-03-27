# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_twilio-app_session',
  :secret      => 'babe8fcb184bb24eb3a041b5194808ac044943dfb09ae5c9ba441623f4738a488ecbf3d6a52f97b11708d64301f74345f546725f622a45bdfb3f429d24dcbdd1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
