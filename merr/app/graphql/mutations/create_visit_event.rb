# frozen_string_literal: true

module Mutations
  class CreateVisitEvent < BaseMutation
    field :visit_event, Types::VisitEventType, null: true
    field :errors, [String], null: true

    argument :time, String, required: true
    argument :location, String, required: true
    argument :field_provider_id, Integer, required: true
    argument :visit_id, Integer, required: true
    argument :event_type, String, required: true

    def resolve(time:, location:, field_provider_id:, visit_id:, event_type:)

      field_provider = FieldProvider.find(field_provider_id)

      event = VisitEvent.new

      event.location          = location
      event.time              = time
      event.field_provider_id = field_provider_id
      event.visit_id          = visit_id
      event.event_type        = event_type

      if event.save
        visit = Visit.find(visit_id)
        visit.skip_push_to_external = true
        PaperTrail.request.whodunnit = field_provider.user.id
        case event_type
        when "en_route"
          visit.update(status: "en_route")
        when "on_site"
          visit.update(status: "on_site")
        when "clocked_in"
          visit.update(status: "clocked")
        when "complete"
          visit.update(status: "completed")
        end

        {
          visit_event: event,
          errors:      nil
        }
      else
        {
          visit_event: nil,
          errors:      event.errors.full_messages
        }
      end
    end
  end
end
