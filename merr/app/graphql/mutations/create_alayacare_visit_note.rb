# frozen_string_literal: true

module Mutations
  class CreateAlayacareVisitNote < BaseMutation
    argument :visit_note_params,
             Types::Params::CreateAlayacareVisitNoteParams,
             required: true

    field :visit_note, Types::AlayacareVisitNoteType, null: true
    field :errors, [String], null: false

    def resolve(visit_note_params:)
      visit_note_params = visit_note_params.to_h
      visit = Visit.find_by(external_id: visit_note_params[:visit_id])

      note = AdminNote.new(notable_type: "Visit", notable_id: visit&.id,
                           content: visit_note_params[:content], creator_id: visit_note_params[:current_user_id])
      if note.save
        {
          visit_note: {
            text:       note.formated_content_for_alayacare,
            created_at: note.created_at
          },
          errors:     []
        }
      else
        {
          visit_note: nil,
          errors:     note.errors.full_messages
        }
      end
    end
  end
end
