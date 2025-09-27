# frozen_string_literal: true

module Types
  class VisitGroupType < Types::BaseObject
    field :id, ID, null: false
    field :visits, [Types::VisitType], null: true
  end
end
