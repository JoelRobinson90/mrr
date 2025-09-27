# typed: true
# frozen_string_literal: true

class TagChangeEventHandler
  def call(event)
    Rails.logger.debug(["*** #{self.class.name}", event, event.data, event.metadata])
    "Early Exit Preventing Changes"
  end
end
