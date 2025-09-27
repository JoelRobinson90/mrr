# typed: true
# frozen_string_literal: true

class CreateOrUpdateAlayacareClientJob < ApplicationJob
  def perform(patient)
    result = Alayacare::ClientCreateOrUpdateService.new(patient, ["all"]).call
    throw result.error unless result.success?
  end
end
