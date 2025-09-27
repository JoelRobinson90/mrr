# frozen_string_literal: true

module Types
  module Params
    class CreateAlayacareVisitNoteParams < GraphQL::Schema::InputObject
      argument :current_user_id, ID, required: true
      argument :visit_id, String, required: true
      argument :content, String, required: true
    end
  end
end
