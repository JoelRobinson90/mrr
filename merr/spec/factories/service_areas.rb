# == Schema Information
#
# Table name: service_areas
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :service_area do
    name { "MyString" }
  end
end
