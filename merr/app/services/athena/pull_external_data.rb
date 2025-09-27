# frozen_string_literal: true

module Athena
  class PullExternalData < ApiClient
    def initialize(klass, url, athena_wrapper_key: nil, allow_create: true,
                   allow_update_by_id: true, allow_update_by_name: true)
      super()
      @klass = klass
      @url = url
      @type = url.split("/").last
      @athena_id_key = "#{@type.chomp('s')}id"
      @athena_name_key = "name"
      @athena_wrapper_key = athena_wrapper_key || @type

      @allow_create = allow_create
      @allow_update_by_name = allow_update_by_name
      @allow_update_by_id = allow_update_by_id

      @ma_name_key = @klass == CancelCode ? :code : :name
    end

    def call
      response = @api.get("#{@url}?limit=5000")

      return response unless response.success?

      items = JSON.parse(response.body)
      # some endpoints return a hash, some an array
      items = items[@athena_wrapper_key] unless items.is_a? Array

      matched = []
      updated_by_id = []
      updated_by_name = []
      created = []
      skipped = []
      failed = []

      items.each do |item|
        athena_name = item[@athena_name_key]
        athena_id = item[@athena_id_key]

        attributes = {
          "athena_id"  => athena_id,
          @ma_name_key => athena_name
        }

        if @type == "customfields"
          category = @athena_wrapper_key == "appointmentcustomfields" ? "Appointment" : "Patient"
          attributes["category"] = category
        end
        attributes["duration"] = item["duration"] if item["duration"].present?
        attributes["timezone"] = item["timezonename"] if @klass.name == "AthenaDepartment"

        # Try finding by ID
        existing = @klass.find_by(athena_id: athena_id)
        if existing
          if existing[@ma_name_key] == athena_name
            matched << athena_name
          elsif @allow_update_by_id
            if existing.update(attributes)
              updated_by_id << athena_name
            else
              failed << failure_msg(existing, athena_name)
            end
          end

          next
        end

        # Try finding by name
        existing = @klass.find_by(@ma_name_key => athena_name)
        if existing && @allow_update_by_name
          if existing.update(attributes)
            updated_by_name << athena_name
          else
            failed << failure_msg(existing, athena_name)
          end
          next
        end

        # Create new MA object if not found
        if @allow_create
          obj = @klass.new(attributes)
          if obj.save
            created << athena_name
          else
            failed << failure_msg(obj, athena_name)
          end
          next
        end

        skipped << athena_name
      end

      only_in_medarrive = @klass.where(athena_id: nil).pluck(@ma_name_key)

      payload = {updated_by_id: updated_by_id, updated_by_name: updated_by_name,
                 created: created, only_in_medarrive: only_in_medarrive,
                 matched: matched, skipped: skipped, failed: failed}
      OpenStruct.new(success?: true,
                     payload:  payload)
    rescue StandardError => e
      OpenStruct.new(success?: false, error: e.message)
    end

    def failure_msg(obj, athena_name)
      "#{athena_name}: #{obj.errors.full_messages.to_sentence}"
    end
  end
end
