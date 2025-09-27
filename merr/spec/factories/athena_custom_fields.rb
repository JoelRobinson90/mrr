# == Schema Information
#
# Table name: athena_custom_fields
#
#  id         :bigint           not null, primary key
#  category   :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  athena_id  :integer
#
FactoryBot.define do
  factory :athena_custom_field do
    name { "MyString" }
    athena_id { 1 }
    category { "Patient" }
  end
end
