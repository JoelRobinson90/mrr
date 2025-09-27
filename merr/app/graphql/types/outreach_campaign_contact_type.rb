# frozen_string_literal: true

module Types
  class OutreachCampaignContactType < Types::BaseObject
    field :id, ID, null: false
    field :outreach_campaign_id, Integer, null: false
    field :kustomer_customer_id, String, null: false
    field :status, String, null: false
    field :kustomer_bulk_id, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
