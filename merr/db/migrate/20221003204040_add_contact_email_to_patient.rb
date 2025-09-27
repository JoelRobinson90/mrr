# frozen_string_literal: true

class AddContactEmailToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :contact_email, :string
  end
end
