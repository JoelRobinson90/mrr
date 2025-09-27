class CreateInsurancePolicies < ActiveRecord::Migration[6.1]
  def change
    create_table :insurance_policies do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :program, null: false, foreign_key: true
      t.integer :insurance_package_id, null: false, default: 0
      t.string :policy_holder_first_name
      t.string :policy_holder_last_name
      t.string :policy_holder_sex
      t.integer :relationship_to_insured_id, null: false, default: 1
      t.string :insurance_id_number, null: false
      t.integer :insurance_sequence_number, null: false, default: 1

      t.timestamps
    end
  end
end
