# typed: true
# frozen_string_literal: true

require "rails_event_store"
require "aggregate_root"
require "arkency/command_bus"

Rails.configuration.to_prepare do
  Rails.configuration.event_store_instance = RailsEventStore::Client.new(
    dispatcher: RubyEventStore::ComposedDispatcher.new(
      RubyEventStore::ImmediateAsyncDispatcher.new(scheduler: RailsEventStore::ActiveJobScheduler.new),
      RubyEventStore::Dispatcher.new
    )
  )

  # Subscribe event handlers below
  RailsEventStoreSubscriptions.new.handlers.each do |handler, events|
    event_store.subscribe(handler, to: events)
  end
end

module Kernel
  def event_store
    Rails.configuration.event_store_instance
  end
end
