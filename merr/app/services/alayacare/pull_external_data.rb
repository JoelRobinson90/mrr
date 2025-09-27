# frozen_string_literal: true

module Alayacare
  class PullExternalData < ::ApplicationService
    def initialize(klass, url, key)
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
      @klass = klass
      @url = url
      @key = key
    end

    def call
      response = GetPaginatedIndex.call(@api, @url)

      return response unless response.success?

      items = filter_old_versions(response.payload)

      items = filter_inactive(items) if @klass.name == "Service"

      matched = []
      updated_by_id = []
      updated_by_name = []
      created = []

      items.each do |item|
        attributes = build_attributes(item)
        ac_name = attributes[@key]
        ac_id = attributes[:alayacare_id]

        existing = @klass.find_by(alayacare_id: ac_id)

        if existing
          if existing[@key] == ac_name
            matched << ac_name
          else
            existing.update!(attributes)
            updated_by_id << ac_name
          end

          next
        end

        existing = @klass.find_by(@key => ac_name)
        if existing
          existing.update!(attributes)
          updated_by_name << ac_name
          next
        end

        @klass.create!(attributes)
        created << ac_name
      end

      only_in_medarrive = @klass.where.not(alayacare_id: items.map {|item| item["id"] }).pluck(@key) || []

      OpenStruct.new(success?: true,
                     payload:  {updated_by_id: updated_by_id, updated_by_name: updated_by_name, created: created,
only_in_medarrive: only_in_medarrive, matched: matched})
    end

    def filter_old_versions(items)
      items.sort_by! {|item| item["id"] }
      items.reverse!
      items.uniq {|item| item[@key.to_s] }
    end

    def filter_inactive(items)
      items.select {|item| item["status"] == "active" }
    end

    def build_attributes(item)
      attributes = {alayacare_id: item["id"]}
      attributes[@key] = item[@key.to_s]
      attributes
    end
  end
end
