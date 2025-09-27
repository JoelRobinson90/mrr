# typed: false
class AddSmsConsentToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :consent_to_text, :boolean, null: false, default: false
  end
end
