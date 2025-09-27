# typed: true
# frozen_string_literal: true

module FormattedPhoneNumber
  extend ActiveSupport::Concern

  included do
    before_save :format_phone_number

    def format_phone_number
      self.phone_number = Utility.sanitize_phone(phone_number) if phone_number.present?
      if respond_to?(:secondary_phone_number) && secondary_phone_number.present?
        self.secondary_phone_number = Utility.sanitize_phone(secondary_phone_number)
      end
    end

    def display_phone_number
      Utility.display_phone(phone_number)
    end
  end
end
