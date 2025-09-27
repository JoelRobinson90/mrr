# typed: true
# frozen_string_literal: true

module FormattedDateOfBirth
  extend ActiveSupport::Concern

  included do
    def date_of_birth=(value)
      if value.is_a?(String)
        self[:date_of_birth] = Utility.sanitize_date(value)
      else
        super
      end
    end

    def display_date_of_birth
      Utility.display_date(date_of_birth)
    end
  end
end
