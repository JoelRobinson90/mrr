# typed: true
# frozen_string_literal: true

module AsyncEventHandler
  extend ActiveSupport::Concern

  included do
    prepend RailsEventStore::CorrelatedHandler
    prepend RailsEventStore::AsyncHandler
  end
end
