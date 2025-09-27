# frozen_string_literal: true

# == Schema Information
#
# Table name: background_job_results
#
#  id         :bigint           not null, primary key
#  error_list :string           default([]), is an Array
#  job_type   :string           not null
#  label      :string
#  message    :string
#  status     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class BackgroundJobResult < ApplicationRecord
  include ActionView::Helpers::DateHelper
  IMPORT_TYPES = %w[data_import medarrive_test medarrive kustomer alayacare].freeze
  OTHER_TYPES = %w[region_creation alayacare_visit_creation backfill_alayacare_data].freeze

  validates :status, inclusion: {in: %w[pending succeeded failed]}
  validates :job_type, inclusion: {in: IMPORT_TYPES + OTHER_TYPES}

  def to_builder
    Jbuilder.new do |background_job|
      background_job.call(self, :id, :error_list, :label, :message, :status)
      background_job.humanized_job_type job_type.humanize
      background_job.date time_ago_in_words(created_at)
    end
  end
end
