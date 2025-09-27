# frozen_string_literal: true

module Types
  class AppConstantsType < Types::BaseObject
    field :patient_sex_options, [String]
    field :patient_language_options, [String]
  end
end
