# typed: true
# frozen_string_literal: true

module VaccinePaperTrail
  extend ActiveSupport::Concern

  def paper_trail_history
    history = PaperTrailScrapbook::LifeHistory.new(self).story
    history = history.map do |e|
      trail_message = e.first
      trail_message = trail_message.gsub(/CovidVaccination|ExtraVaccineRecipient/, "#{self.papertrail_display_name}'s #{self.class}")
      [trail_message, e[1]]
    end
    return history if history.length >= 1
  end
end
