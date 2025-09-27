# frozen_string_literal: true

module Kustomer
  class GetSearchResults < ::ApplicationService
    attr_accessor :search_id

    PAGE_SIZE = 500
    MAX_PAGE = 20

    # Paginates through a saved search and returns first all records
    # If > 10,000 records, attempts to circumvent hard API limit
    def initialize(search_id)
      @api = Authentication::Api.new(Authentication::KustomerBroker)
      @search_id = search_id
    end

    def call
      search_res = Kustomer::GetSearchSettings.call(search_id)
      return search_res unless search_res.success?

      search_data = JSON.parse(search_res.body)["data"]["attributes"]["data"]
      search_data["sort"] = [{customer_updated_at: "asc"}]

      page = 1
      results_h = {}
      updated_at_filter = nil

      loop do
        and_filter = updated_at_filter ? (search_data["and"] || []) + [updated_at_filter] : search_data["and"]
        post_data = search_data.merge("and" => and_filter)

        res = Kustomer::Helper.parse_response(@api.post("customers/search?page=#{page}&pageSize=#{PAGE_SIZE}",
                                                        post_data))

        unless res.success?
          # Return any results accumulated so far
          return OpenStruct.new(success?: false, error: res.error, payload: results_h.values)
        end

        body = JSON.parse(res.body)
        results_h.merge!(body["data"].index_by {|result| result["id"] })

        if page == body["meta"]["totalPages"]
          return OpenStruct.new(success?: true, payload: results_h.values)
        elsif page == MAX_PAGE
          # If reached max page but there are still more results, set an updated_at filter to continue fetching
          last_updated_at = body["data"].last["attributes"]["updatedAt"]
          # If the last updated_at fetched isn't greater than the previous filter value, this strategy won't work
          if updated_at_filter && last_updated_at <= updated_at_filter["customer_updated_at"]["gte"]
            return OpenStruct.new(success?: false, error: "Unable to fetch all results", payload: results_h.values)
          end

          page = 1
          updated_at_filter = {"customer_updated_at" => {"gte" => last_updated_at}}
        else
          page += 1
        end
      end
    end
  end
end
