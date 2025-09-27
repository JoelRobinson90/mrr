# typed: true
# frozen_string_literal: true

module ExternalId
  extend ActiveSupport::Concern

  included do
    before_validation :generate_external_id

    validates :external_id, uniqueness: true

    def generate_external_id
      if external_id.blank?
        id_available = false
        until id_available
          new_external_id = "#{self.class.name}_#{SecureRandom.base58(16)}"
          id_available = self.class.find_by(external_id: new_external_id).nil?
        end

        self.external_id = new_external_id

        # FIXME: part of migration process.  Remove as soon as external_id is being used as the key in all external API calls.
        if instance_of?(Patient) &&
           medical_record_number.present? &&
           Patient.find_by(external_id: medical_record_number).blank?

          self.external_id = medical_record_number
        end
      end
    end

    def self.find_by_maybe_external_id(id: nil, external_id: nil)
      if id
        where(id: id).first
      elsif external_id
        where(external_id: external_id).first
      end
    end
  end
end
