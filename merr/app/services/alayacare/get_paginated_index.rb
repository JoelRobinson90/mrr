# frozen_string_literal: true

module Alayacare
  class GetPaginatedIndex < ::ApplicationService
    def initialize(api, url, key: :items, start_page: 1, end_page: nil)
      @api = api
      @url = url
      @key = key.to_s
      @start_page = start_page
      @end_page = end_page
      @combined_result = []

      # one endpoint has broken pagination metadata.  The workaround
      # is to ignore it and keep fetching until an incomplete block
      # is found.  For some reasone this also breaks with the max
      # results per page.
      # Only use the workaround for the bad endpoint, because it
      # will blow up if the number of items is devisible by 50.
      @bad_metadata = url.include? "scheduler/services/forms"

      @visits_per_page = @bad_metadata ? 30 : 100
    end

    def call
      fetch_index(page: @start_page)
    end

    def fetch_index(page:)
      # either start a new query string, or append onto an existing one
      join_character = @url.include?("?") ? "&" : "?"

      response = @api.get("#{@url}#{join_character}page=#{page}&count=#{@visits_per_page}")

      return OpenStruct.new(success?: false, error: response.body) unless response.success?

      body = JSON.parse(response.body)

      @combined_result.concat(body[@key])

      # Base case for recursive function
      if should_continue_recursing?(body, page)
        fetch_index(page: page + 1)
      else
        OpenStruct.new(success?: true, payload: @combined_result)
      end
    end

    def should_continue_recursing?(body, page)
      if @bad_metadata
        body[@key].length == @visits_per_page
      else
        last_page = @end_page.present? ? [body["total_pages"], @end_page].min : body["total_pages"]

        last_page > page
      end
    end
  end
end
