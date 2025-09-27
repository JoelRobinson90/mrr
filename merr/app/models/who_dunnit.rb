# frozen_string_literal: true

# typed: true
# Class for displaying user names for papertrail
class WhoDunnit

  def self.find(id)
    WhoDunnit.unknown_user(id)
  end

  def self.unknown_user(id)
    begin
      persons = User.find_by(id: id)
      return persons.full_name if persons

      person_by_email = User.find_by(email: id)
      return person_by_email.full_name if person_by_email
    rescue StandardError => e
      Sentry.capture_exception(e)
    end

    "Unable to determine user from #{id}"
  end
end
