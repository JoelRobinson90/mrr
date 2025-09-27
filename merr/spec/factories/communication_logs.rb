# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: communication_logs
#
#  id                 :bigint           not null, primary key
#  body               :text
#  category           :string
#  communication_type :string
#  context_type       :string           indexed => [context_id]
#  destination        :string
#  direction          :string           default("outbound"), not null
#  event_trigger      :string
#  reciept            :string
#  sender             :string
#  subject            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  context_id         :bigint           indexed => [context_type]
#  patient_id         :bigint           not null, indexed
#
# Indexes
#
#  index_communication_logs_on_context_type_and_context_id  (context_type,context_id)
#  index_communication_logs_on_patient_id                   (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#
FactoryBot.define do
  factory :communication_log do
    communication_type { "sms" }
    body { Faker::Lorem.paragraph }
    subject { "Your upcomming appointment" }
    destination { Faker::PhoneNumber.cell_phone }
    sender { "system_user" }
    category { "upcommign appointment" }
    context { create(:appointment) }
    patient { create(:patient) }
    direction { "outbound" }
  end
end
