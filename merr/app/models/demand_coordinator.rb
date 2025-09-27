# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: demand_coordinators
#
#  id                :bigint           not null, primary key
#  first_name        :string
#  last_name         :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_partner_id :bigint           not null, indexed
#
# Indexes
#
#  index_demand_coordinators_on_demand_partner_id  (demand_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
class DemandCoordinator < ApplicationRecord
  include UserAccount

  belongs_to :demand_partner

  def session_timeout_in
    15.minutes
  end
end
