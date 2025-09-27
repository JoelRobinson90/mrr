# frozen_string_literal: true

module Types
  class OutreachCampaignType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :rate_per_hour, Integer, null: false
    field :kustomer_tag_id, String, null: false
    field :kustomer_search_id, String, null: false
    field :kustomer_conversation_fields, GraphQL::Types::JSON, null: false
    field :active, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :contacts_total_count, Integer, null: false
    def contacts_total_count
      object.contacts.count
    end

    # Contact counts for each possible state
    OutreachCampaignContact.aasm.states.map(&:name).each do |state|
      field :"contacts_#{state}_count", Integer, null: false
      define_method :"contacts_#{state}_count" do
        object.contacts.public_send(state).count
      end
    end
  end
end
