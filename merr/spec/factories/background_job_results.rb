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
FactoryBot.define do
  factory :background_job_result do
    status { "failed" }
    job_type { "data_import" }
    label { "Test run" }
    message { "Didn't work" }
    error_list { %w[Bad Worse] }
  end
end
