# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_types
#
#  id                :bigint           not null, primary key
#  duration          :integer          default(0), not null
#  name              :string           not null
#  outreach_visit    :boolean          default(FALSE)
#  plus_ones_enabled :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  alayacare_id      :string
#  athena_id         :integer
#  ma_id             :string           indexed
#  program_id        :bigint           indexed
#
# Indexes
#
#  index_visit_types_on_ma_id       (ma_id)
#  index_visit_types_on_program_id  (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (program_id => programs.id)
#
FactoryBot.define do
  factory :visit_type do
    name { "General Checkup" }
    duration { 90 }
    alayacare_id { "1" }
  end
end
