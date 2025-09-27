# frozen_string_literal: true

module Types
  class AlayacareVisitNoteType < Types::BaseObject
    field :created_at, String, null: false
    field :text, String, null: false
  end
end
