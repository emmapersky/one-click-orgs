# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_oneclickorgs_session',
  :secret => 'c33af3809ae1fc44bb95b728954f2b39985826a4914adaf801f8095cfd59cc89c0a36cb7d6208ff9192fe83d4a257697cbc41366ffc47aea11fb51dd48ae13c7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
