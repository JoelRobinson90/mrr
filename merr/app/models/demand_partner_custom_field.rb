# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_partner_custom_fields
#
#  id                :bigint           not null, primary key
#  crm_field_name    :string
#  csv_column_name   :string           not null
#  data_type         :string           not null
#  display_name      :string
#  ehr_field_name    :string
#  v2                :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_partner_id :bigint           indexed
#
# Indexes
#
#  index_demand_partner_custom_fields_on_demand_partner_id  (demand_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
class DemandPartnerCustomField < ApplicationRecord
  belongs_to :demand_partner, optional: true
end
