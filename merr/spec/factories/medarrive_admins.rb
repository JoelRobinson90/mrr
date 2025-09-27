# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: medarrive_admins
#
#  id           :bigint           not null, primary key
#  first_name   :string
#  last_name    :string
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :medarrive_admin do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.cell_phone }

    after :build do |record|
      record.user = FactoryBot.create(:user, account: record) unless record.user
    end
  end
end
