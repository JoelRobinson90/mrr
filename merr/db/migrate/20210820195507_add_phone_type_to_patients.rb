# frozen_string_literal: true

class AddPhoneTypeToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :phone_number_type, :string
    add_column :patients, :secondary_phone_number_type, :string
  end
end
