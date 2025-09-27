# frozen_string_literal: true

module Api
  module V1
    class VisitEventController < ApiController
      skip_before_action :verify_authenticity_token

      def show
        event = VisitEvent.where(visit_id:          params[:visit_id],
                                 field_provider_id: params[:field_provider_id]).order("id DESC").first
        if event
          render json: {event: event}, status: :ok
        else
          render body: nil, status: :no_content
        end
      end

      def create
        event = VisitEvent.new

        event[:location] = params[:visit_event][:location]
        event[:time] = params[:visit_event][:time]
        event[:field_provider_id] = params[:visit_event][:field_provider_id]
        event[:visit_id] = params[:visit_event][:visit_id]
        event[:event_type] = params[:visit_event][:event_type]

        if event.save
          visit = Visit.find(params[:visit_event][:visit_id])
          case params[:visit_event][:event_type]
          when "clocked_in"
            visit.update(status: "clocked")
          when "complete"
            visit.update(status: "completed")
          end
          render body: nil, status: :ok
        else
          render body: event.errors.full_messages, status: :bad_request
        end
      end
    end
  end
end
