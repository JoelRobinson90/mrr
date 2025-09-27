# frozen_string_literal: true

module Mutations
  class CancelVisit < BaseMutation
    field :visit, Types::VisitType, null: true
    field :errors, [String], null: true

    argument :id, ID, required: false
    argument :ma_id, ID, required: false
    argument :cancel_code_id, ID, required: true
    argument :note, String, required: false

    def resolve(cancel_code_id:, id: nil, ma_id: nil, note: nil)
      visit = Visit.find_by_maybe_ma_id(id: id, ma_id: ma_id)
      return {visit: nil, errors: ["Invalid visit"]} unless visit && can?(:update, visit)

      # +1 logic is virtually identical to +1 login in alayacare_update_visit--should consolidate
      # if the visit has +1 patients
      if visit.visit_group.present?
        visit_group_visits = visit.visit_group.visits

        # removes current visit from the visits inside visit group
        visit_group_visits = visit_group_visits.reject {|v| v.id == visit.id }

        if visit_group_visits.size == 1
          # if after removing existing visit the visit group only have 1 visit left then delete visit group
          visit_group_visits.first.visit_group.destroy
        end

        # removes visit group from existing visit to avoid carrying over +1 patients
        visit.visit_group_id = nil
      end

      visit.mark_canceled(cancel_code_id)

      if visit.save
        note_obj = AdminNote.new(notable_type: "Visit", notable_id: visit.id,
                                 content: note, creator_id: current_user.id)
        note_obj.save

        {
          visit:  visit,
          errors: []
        }
      else
        {
          visit:  nil,
          errors: visit.errors.full_messages
        }
      end
    end
  end
end
