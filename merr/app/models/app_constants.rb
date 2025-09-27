# frozen_string_literal: true

class AppConstants
  def patient_sex_options
    Patient::SEXES
  end

  def patient_language_options
    Patient::LANGUAGES_LONGFORM
  end
end
