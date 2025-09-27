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
require "rails_helper"

RSpec.describe BackgroundJobResult, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
