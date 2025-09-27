# typed: true
# frozen_string_literal: true

module RequiredPhysicalAddress
  extend ActiveSupport::Concern

  included do
    has_one :address, as: :addressable, dependent: :destroy, required: true

    accepts_nested_attributes_for :address

    delegate :address_line_one, :address_line_two, :city, :state, :zipcode, :latitude, :longitude,
             :timezone, to: :address, allow_nil: true

    validates :address, presence: true
    validates_associated :address

    def lat_long
      if address.present? && address.latitude.present? && address.longitude.present?
        "#{address.latitude},#{address.longitude}"
      end
    end
  end
end
