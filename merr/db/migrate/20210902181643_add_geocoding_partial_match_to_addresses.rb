# frozen_string_literal: true

class AddGeocodingPartialMatchToAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :addresses, :geocoding_partial_match, :boolean
    add_column :addresses, :geocoding_approximate_result, :boolean
  end
end
