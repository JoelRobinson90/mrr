module Athena
  class ApiClient < ::ApplicationService
    def initialize
      @api = Authentication::Api.new(Authentication::AthenaBroker)
    end
  end
end