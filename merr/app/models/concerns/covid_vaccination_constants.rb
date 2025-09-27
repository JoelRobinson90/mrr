# frozen_string_literal: true

# typed: true

module CovidVaccinationConstants
  extend ActiveSupport::Concern
  included do
    # Allowing dose values for existent values, but dose is going to be saved in a separate field moving forward.
    VACCINE_TYPES_VALIDATION = [
      "Moderna First Dose",
      "Moderna Second Dose",
      "Pfizer First Dose",
      "Pfizer Second Dose",
      "Johnson & Johnson",
      "Moderna",
      "Pfizer"
    ].freeze

    VACCINE_TYPES = [
      "Moderna",
      "Pfizer",
      "Johnson & Johnson"
    ].freeze

    VACCINE_ROUTE = %w[
      Intradermal
      Intramuscular
      Nasal
      Oral
      Subcutaneous
    ].freeze

    VACCINE_INJECTION_SITE = [
      "Left Upper Arm",
      "Left Deltoid",
      "Left Gluteous Medius",
      "Left Lower Forearm",
      "Left Thigh",
      "Left Vastus Lateralis",
      "Right Upper Arm",
      "Right Deltoid",
      "Right Gluteous Medius",
      "Right Lower Forearm",
      "Right Thigh",
      "Right Vastus Lateralis"
    ].freeze

    VACCINE_DOSE = [
      "Dose #1",
      "Dose #2",
      "Dose #3",
      "Booster"
    ].freeze
  end
end
