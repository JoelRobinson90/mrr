# typed: true
class CreateTrainings < ActiveRecord::Migration[6.0]
  def change
    create_table :trainings do |t|
      t.string :name
      t.string :training_url
      t.string :quiz_url
      t.boolean :medarrive_required, default: false

      t.timestamps
    end

    create_table :field_org_trainings do |t|
      t.references :training, null: false, foreign_key: true
      t.references :field_org, null: false, foreign_key: {on_delete: :cascade}
      t.boolean :required, default: false

      t.timestamps
    end

    create_table :field_provider_trainings do |t|
      t.references :training, null: false, foreign_key: true
      t.references :field_provider, null: false, foreign_key: true
      t.integer :quiz_score
      t.datetime :validated_at
      t.references :validated_by, null: true, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end