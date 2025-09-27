# == Schema Information
#
# Table name: cancel_codes
#
#  id           :bigint           not null, primary key
#  code         :string           not null
#  description  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  alayacare_id :integer
#  athena_id    :integer
#  ma_id        :string           indexed
#
# Indexes
#
#  index_cancel_codes_on_ma_id  (ma_id)
#
FactoryBot.define do
  factory :cancel_code do
    alayacare_id { 1 }
    code { "CUS_RESCHED" }
    description { "Customer requested reschedule" }
  end
end
