# typed: true
class CreateCertifications < ActiveRecord::Migration[6.0]
  def change
    create_table :certifications do |t|
      t.string :name
      t.boolean :medarrive_required, default: false
      
      t.timestamps
    end

    create_table :field_org_certifications do |t|
      t.references :certification, null: false, foreign_key: true
      t.references :field_org, null: false, foreign_key: {on_delete: :cascade}
      t.boolean :required, default: false

      t.timestamps
    end

    create_table :field_provider_certifications do |t|
      t.references :certification, null: false, foreign_key: true
      t.references :field_provider, null: false, foreign_key: true
      t.date :effective_date
      t.date :expiration_date
      t.string :license_number
      t.string :document
      t.datetime :validated_at
      t.references :validated_by, null: true, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
