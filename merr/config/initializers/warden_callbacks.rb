# frozen_string_literal: true

# typed: true
# Set Sentry user on every request
# This might work just as well with after_authentication.

Warden::Manager.after_set_user do |user, _auth, _opts|
  Sentry.set_user(id: user.id)
end
