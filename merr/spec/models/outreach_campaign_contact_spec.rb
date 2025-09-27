# == Schema Information
#
# Table name: outreach_campaign_contacts
#
#  id                   :bigint           not null, primary key
#  status               :string           default("created"), not null, indexed
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  kustomer_bulk_id     :string
#  kustomer_customer_id :string           not null, indexed => [outreach_campaign_id]
#  outreach_campaign_id :bigint           not null, indexed => [kustomer_customer_id], indexed
#
# Indexes
#
#  index_outreach_campaign_contacts_on_campaign_id_and_customer_id  (outreach_campaign_id,kustomer_customer_id) UNIQUE
#  index_outreach_campaign_contacts_on_outreach_campaign_id         (outreach_campaign_id)
#  index_outreach_campaign_contacts_on_status                       (status)
#
# Foreign Keys
#
#  fk_rails_...  (outreach_campaign_id => outreach_campaigns.id)
#
require 'rails_helper'

RSpec.describe OutreachCampaignContact, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
