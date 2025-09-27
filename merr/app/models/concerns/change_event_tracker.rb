# typed: true
# frozen_string_literal: true

module ChangeEventTracker
  extend ActiveSupport::Concern

  # If status changes, broadcast generic event with old and new status
  # Use after_commit so we're sure the change is reflected in the db
  # TODO: if using a state machine, migrate some of this logic to that
  # TODO: we may want to use specific events for each state change
  included do
    attr_reader :_event_change

    before_save :check_for_change_events
    after_commit :create_change_event, if: :_event_change
  end

  def check_for_change_events
    @_event_change = {
      dirty_fields: changed
    }

    changed.each do |att|
      @_event_change[att.to_sym] = {
        was: send("#{att}_was"),
        to:  send(att)
      }
    end
  end

  def create_change_event
    event_notification = "#{self.class.name}ChangeEvent"
    # Check to see if an event hander is defined for this class
    return unless defined?(event_notification)

    event_store.publish(
      event_notification.constantize.new(
        data: {
          object_class: self.class,
          object_id:    id,
          meta:         @_event_change
        }
      ),
      stream_name: stream_name
    )

    # If there is an alteration in the tag list,
    # call for the tag change handler
    if @_event_change[:dirty_fields].include?(:tag_list)
      event_store.publish(
        TagChangeEvent.new(
          data: {
            object_class: self.class,
            object_id:    id,
            meta:         @_event_change
          }
        ),
        stream_name: stream_name
      )
    end

    @_event_change = nil
  end
end
