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
class OutreachCampaignContact < ApplicationRecord
  include AASM

  # NOTE: insert_all being done in Outreach::ImportCampaignSearch
  #       Make sure it stays valid when updating validations and callbacks
  
  STATUSES = %w[created pending success failed]

  belongs_to :outreach_campaign, inverse_of: :contacts

  validates :kustomer_customer_id, presence: true, uniqueness: { scope: :outreach_campaign_id }
  validates :status, inclusion: { in: STATUSES }

  # scope :created, -> { where(status: "created") }
  # scope :pending, -> { where(status: "pending") }
  # scope :success, -> { where(status: "success") }
  # scope :failed,  -> { where(status: "failed") }

  aasm column: :status do
    state :created, initial: true
    state :pending, :success, :failed

    event :mark_pending do
      transitions from: :created, to: :pending
    end

    event :mark_success do
      transitions from: [:created, :pending], to: :success
    end

    event :mark_failed do
      transitions from: [:created, :pending], to: :failed
    end
  end
end
