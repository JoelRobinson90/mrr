# typed: true
# frozen_string_literal: true

class RailsEventStoreSubscriptions
  # Events => Handlers
  def setup
    {
      AppointmentChangeEvent => [
        AppointmentChangeEventHandler
      ],
      TagChangeEvent         => [
        TagChangeEventHandler
      ]
    }
  end

  # Handlers => Events
  # Converting from events linked to handlers,
  # to Handlers linked to events. This helps with both debugging
  # and to make the passing of this block to Rails Event Store
  def handlers
    setup.each_with_object({}) do |(event, handlers), memo|
      handlers.each do |handler|
        memo[handler] ||= []
        memo[handler] << event
      end
    end
  end
end
