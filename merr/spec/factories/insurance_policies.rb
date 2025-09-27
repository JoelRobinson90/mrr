# == Schema Information
#
# Table name: insurance_policies
#
#  id                         :bigint           not null, primary key
#  insurance_id_number        :string           not null
#  insurance_sequence_number  :integer          default(1), not null
#  policy_holder_first_name   :string
#  policy_holder_last_name    :string
#  policy_holder_sex          :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  insurance_package_id       :integer          default(0), not null
#  patient_id                 :bigint           not null, indexed
#  program_id                 :bigint           not null, indexed
#  relationship_to_insured_id :integer          default(1), not null
#
# Indexes
#
#  index_insurance_policies_on_patient_id  (patient_id)
#  index_insurance_policies_on_program_id  (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (program_id => programs.id)
#
FactoryBot.define do
  factory :insurance_policy do
    association :patient, strategy: :create
    association :program, strategy: :create
    insurance_package_id { 0 }
    policy_holder_first_name { Faker::Name.first_name }
    policy_holder_last_name { Faker::Name.last_name }
    policy_holder_sex { %w[Male Female].sample }
    relationship_to_insured_id { 1 }
    insurance_id_number { Faker::Number.number(digits: 6).to_s }
    insurance_sequence_number { 1 }
  end
end
