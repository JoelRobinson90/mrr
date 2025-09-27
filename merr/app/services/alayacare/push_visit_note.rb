# typed: true
# frozen_string_literal: true

module Alayacare
  class PushVisitNote < ApiClient
    def initialize(id_type, id, text)
      super()

      base_url = "scheduler/visits"
      base_url += "/by_id" if id_type == :external_id

      @url = "#{base_url}/#{id}/notes"
      @text = text
    end

    def call
      @api.post(@url, {text: @text})
    end
  end
end
