# frozen_string_literal: true

# == Schema Information
#
# Table name: athena_departments
#
#  id                :bigint           not null, primary key
#  generic_timezone  :string           not null
#  name              :string           not null
#  timezone          :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  athena_id         :integer          not null
#  demand_partner_id :bigint           not null, indexed
#
# Indexes
#
#  index_athena_departments_on_demand_partner_id  (demand_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
class AthenaDepartment < ApplicationRecord
  belongs_to :demand_partner, optional: false

  validates :name, :timezone, :generic_timezone, :athena_id, presence: true

  before_validation :link_demand_partner_by_name
  before_validation :set_generic_timezone_abbreviation

  def set_generic_timezone_abbreviation
    self.generic_timezone = Address.convert_to_generic_timezone(timezone)
  end

  def link_demand_partner_by_name
    return if demand_partner_id.present?

    DemandPartner.all.find_each do |dp|
      # link on exact name match
      if name.strip == dp.name.strip
        self.demand_partner = dp
        return
      end

      # link on name plus TZ match
      # matches DP name plus anything in parentheses, like "Name (EST)"
      if name.strip =~ /^#{Regexp.escape(dp.name.strip)} ?\(.*\)$/
        self.demand_partner = dp
        return
      end
    end
  end
end
