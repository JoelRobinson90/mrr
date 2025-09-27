# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: sms_templates
#
#  id                :bigint           not null, primary key
#  message_body      :string           not null
#  message_type      :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_partner_id :bigint           not null, indexed
#
# Indexes
#
#  index_sms_templates_on_demand_partner_id  (demand_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
FactoryBot.define do
  factory :sms_template do
    association :demand_partner, strategy: :create

    message_type { SmsTemplate::APPOINTMENT_TYPES.sample }
    message_body { Faker::Lorem.paragraph }
  end
end
