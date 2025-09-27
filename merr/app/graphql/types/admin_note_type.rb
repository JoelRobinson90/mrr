# frozen_string_literal: true

module Types
  class AdminNoteType < Types::BaseObject
    field :id, ID, null: true
    field :ma_id, ID, null: true
    field :content, String, null: true
    field :notable_type, String, null: false
    field :notable_id, Integer, null: false
    field :creator_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :creator, Types::CreatorType, null: true
    field :text, String, null: true, method: :formated_content_for_alayacare
    field :notable_ma_id, String, null: false
  end
end
