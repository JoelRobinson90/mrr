# typed: strict
# frozen_string_literal: true

# == Schema Information
#
# Table name: field_dispatchers
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
#  index_field_dispatchers_on_field_org_id  (field_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (field_org_id => field_orgs.id)
#
class FieldDispatcher < ApplicationRecord
  include UserAccount
  include FieldAccount
end
