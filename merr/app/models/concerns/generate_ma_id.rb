# typed: true
# frozen_string_literal: true

module GenerateMaId
  extend ActiveSupport::Concern

  included do
    before_save :generate_ma_id, unless: :ma_id?

    def generate_ma_id
      prefix = EnvHelper.env_or_nil("MA_ID_PREFIX")&.downcase
      if prefix.blank? # devs who haven't updated .env yet
        prefix = "dev#{[*('a'..'z'), *('0'..'9')].sample(4).join}"
        ENV["MA_ID_PREFIX"] = prefix
      end

      id_str = get_ma_sequence_identifier
      return if id_str.blank?

      self.ma_id = "#{prefix}_#{ma_object_payload_type}_#{id_str}"
    end

    def get_ma_sequence_identifier
      sequence_key = "#{self.class.name.underscore}_ma_id"
      ActiveRecord::Base.nextval(sequence_key)
    end

    def ma_object_message_group
      ma_id
    end

    def ma_object_payload_type(payload_type = nil)
      payload_type || self.class.name
    end
  end
end
