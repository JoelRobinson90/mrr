class CreatePreferredProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :provider_preferences do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :field_provider, null: false, foreign_key: true
      t.string :source, null: false, default: "care_team"

      t.timestamps
    end

    add_column :scheduler_logs, :options_without_any_preferred_provider_count, :integer
    add_column :scheduler_logs, :options_without_full_preferred_provider_count, :integer
    add_column :scheduler_logs, :full_preferred_provider_option_chosen, :boolean
    add_column :scheduler_logs, :partial_preferred_provider_option_chosen, :boolean

    add_column :visit_resource_requirements, :use_preferred_provider, :boolean, default: true
  end
end
