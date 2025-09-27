# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: field_admins
#
#  id           :bigint           not null, primary key
#  first_name   :string
#  last_name    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  field_org_id :bigint           not null, indexed
#
# Indexes
#
#  index_field_admins_on_field_org_id  (field_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (field_org_id => field_orgs.id)
#
FactoryBot.define do
  factory :field_admin do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    association :field_org

    after :build do |record|
      unless record.user
        # TODO: Fix the bug where this doesn't prevent `create(:field_admin_user)` from
        # creating two users, not 1, because this after_hook is still executing.
        record.user = FactoryBot.build(:user, account: record)
      end
    end
  end
end
