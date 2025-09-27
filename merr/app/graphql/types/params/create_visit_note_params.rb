# frozen_string_literal: true

module Types
  module Params
    class CreateVisitNoteParams < GraphQL::Schema::InputObject
      argument :content, String, required: true
      argument :current_user_id, Integer, required: false
      argument :visit_id, Integer, required: false
      argument :visit_ma_id, ID, required: false
    end
  end
end
