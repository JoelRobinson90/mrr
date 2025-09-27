class AddConsentToEmailAndPreferredContactToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :consent_to_email, :boolean, null: false, default: false
    add_column :patients, :preferred_contact_method, :string
  end
end
