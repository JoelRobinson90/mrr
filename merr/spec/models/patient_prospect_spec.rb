# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: patient_prospects
#
#  id                    :bigint           not null, primary key
#  deleted_at            :datetime         indexed
#  diagnosis             :string           is an Array
#  discharge_end         :date
#  discharge_start       :date
#  medical_record_number :string
#  notes                 :string
#  preferred_language    :string
#  zipcode               :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  demand_partner_id     :bigint           indexed
#
# Indexes
#
#  index_patient_prospects_on_deleted_at         (deleted_at)
#  index_patient_prospects_on_demand_partner_id  (demand_partner_id)
#
require "rails_helper"

RSpec.describe PatientProspect, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
