# typed: true
# frozen_string_literal: true

module Alayacare
  class ClientPdfUploadService < ::ApplicationService
    def initialize(order, pdf)
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
      @pdf = Base64.encode64(pdf)
      @alayacare_client_id = false
      @endpoint = "files/client/#{@alayacare_client_id}/"
    end

    def call
      @api.post(@endpoint, body)
    end

    def body
      {
        file: @pdf,
        id:   @alayacare_client_id,
        path: "clinical_summary"
      }
    end
  end
end
