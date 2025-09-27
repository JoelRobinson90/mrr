# frozen_string_literal: true

module Types
  class VisitNoteType < Types::BaseObject
    field :id, ID, null: false
    field :ma_id, ID, null: true
    field :content, String, null: true
    field :notable_type, String, null: false
    field :notable_id, Integer, null: false
    field :creator_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
