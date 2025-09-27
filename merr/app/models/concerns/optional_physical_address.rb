# typed: true
# frozen_string_literal: true

module OptionalPhysicalAddress
  extend ActiveSupport::Concern

  included do
    has_one :address, as: :addressable, dependent: :destroy, required: false

    accepts_nested_attributes_for :address

    def lat_long
      if address.present? && address.latitude.present? && address.longitude.present?
        "#{address.latitude},#{address.longitude}"
      end
    end
  end
end
