# frozen_string_literal: true

# typed: true

# == Schema Information
#
# Table name: external_accounts
#
#  id                :bigint           not null, primary key
#  first_name        :string
#  last_name         :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_partner_id :bigint           indexed
#
# Indexes
#
#  index_external_accounts_on_demand_partner_id  (demand_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
class ExternalAccount < ApplicationRecord
  include UserAccount

  has_many :ext_acct_programs
  has_many :programs, through: :ext_acct_programs
  belongs_to :demand_partner, dependent: :destroy, optional: true

  def organization_name
    demand_partner&.name
  end
end
