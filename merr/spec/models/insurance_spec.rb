# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: insurances
#
#  id               :bigint           not null, primary key
#  bin_number       :string
#  effective_date   :date
#  name             :string
#  plan_description :text
#  renewal_date     :date
#  rx_group         :string
#  rx_pcn           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  group_id         :string
#  member_id        :string
#  patient_id       :bigint           not null, indexed
#
# Indexes
#
#  index_insurances_on_patient_id  (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id) ON DELETE => cascade
#
require "rails_helper"

RSpec.describe Insurance, type: :model do
end
