# frozen_string_literal: true

# typed: true
class GeoJsonBuilder < ApplicationService
  require "active_support/inflector"
  require "jbuilder"

  def initialize(addressables)
    @addressables = addressables
  end

  def call
    Jbuilder.new do |json|
      json.type "FeatureCollection"
      json.features @addressables do |addressable|
        next if addressable.address.blank?
        next if addressable.address.latitude.blank?

        json.type "Feature"
        json.geometry do
          json.type "Point"
          json.coordinates [
            # can call .to_f here, but seems to work as a string
            # and I don't want to risk subtle rounding errors.
            addressable.address.longitude,
            addressable.address.latitude
          ]
        end
        json.properties do
          json.id addressable.id
          json.id addressable.id
          if addressable.instance_of?(Appointment)
            json.accepted addressable.status == "Awaiting Scheduling"
            json.route_index addressable.route_index + 1 if addressable.route_index.present?
            json.patient_name addressable.patient.full_name
            json.patient_id addressable.patient_id
          end
        end
      end
    end.attributes!
  end
end
