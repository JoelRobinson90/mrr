# frozen_string_literal: true

module Kustomer
  class Helper
    def self.get_kustomer_id(api, mrn)
      kustomer_id = nil

      if mrn.present?
        id_resp = api.get("customers/externalId=#{mrn}")
        kustomer_id = JSON.parse(id_resp.body).dig("data", "id")
      end

      kustomer_id
    end

    def self.parse_response(resp)
      # check for errors from Kustomer
      if resp.body.present?
        errors = JSON.parse(resp.body)["errors"]
        if errors.present?
          errors_to_string = errors.collect do |e|
            parse_kustomer_error(e)
          end

          return OpenStruct.new({success?: false,
                                 error:    errors_to_string.join(", ")})
        end
      end

      # success or API connection failiure
      resp
    end

    def self.parse_kustomer_error(err)
      return err["detail"] if err["detail"]
      return "#{err['source']['pointer']} #{err['title']}" if err["source"]

      err
    end
  end
end
