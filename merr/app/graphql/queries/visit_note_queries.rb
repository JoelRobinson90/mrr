# frozen_string_literal: true

module Queries
  module VisitNoteQueries
    include Routing::Helpers

    def get_visit_notes(params)
      visit_notes = AdminNote.where(notable_type: "Visit", notable_id: params[:notable_id]).order(created_at: :desc)
    end
  end
end
