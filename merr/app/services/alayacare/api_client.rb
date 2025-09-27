module Alayacare
  class ApiClient < ::ApplicationService
    include ServiceCodes
    def initialize
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
    end
  end
end