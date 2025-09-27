# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: admin_notes
#
#  id           :bigint           not null, primary key
#  content      :string
#  notable_type :string           not null, indexed => [notable_id]
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :integer          indexed
#  ma_id        :string           indexed
#  notable_id   :bigint           not null, indexed => [notable_type]
#
# Indexes
#
#  index_admin_notes_on_creator_id                   (creator_id)
#  index_admin_notes_on_ma_id                        (ma_id)
#  index_admin_notes_on_notable_type_and_notable_id  (notable_type,notable_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
FactoryBot.define do
  # An Admin note on a Patient
  factory :admin_note do
    content { Faker::Lorem.words }
    association :notable, factory: :patient
    association :creator, factory: :super_admin_user

    trait :by_field_admin do
      association :creator, factory: :field_admin_user
    end

    trait :on_patient do
      association :notable, factory: :patient
    end

    trait :on_visit do
      association :notable, factory: :visit
    end

    trait :on_appointment do
      association :notable, factory: :appointment
    end

    trait :on_provider do
      association :notable, factory: :provider
    end
  end
end
