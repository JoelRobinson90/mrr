# frozen_string_literal: true

module Mutations
  class CreateVisitNote < BaseMutation
    argument :visit_note_params,
             Types::Params::CreateVisitNoteParams,
             required: true

    field :visit_note, Types::AdminNoteType, null: true
    field :errors, [String], null: false

    def resolve(visit_note_params:)
      visit_note_params = visit_note_params.to_h
      visit = Visit.find_by_maybe_ma_id(
        id:    visit_note_params[:visit_id],
        ma_id: visit_note_params[:visit_ma_id]
      )

      creator_id = visit_note_params[:current_user_id] || current_user.id

      note = AdminNote.new(notable_type: "Visit", notable_id: visit&.id,
                           content: visit_note_params[:content], creator_id: creator_id)

      return {visit_note: nil, errors: [unauthorized_error]} unless can?(:create, note)

      if note.save
        {
          visit_note: note,
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
