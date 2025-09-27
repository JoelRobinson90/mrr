# frozen_string_literal: true

class MultiResourceScheduling < ActiveRecord::Migration[6.1]
  def change
    add_column :field_providers, :role, :string, default: "field_provider"

    add_column :scheduler_logs, :pre_merge_slots, :string

    create_table :visit_resources do |t|
      t.references :field_provider, foreign_key: true
      t.references :visit, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.boolean :in_home, null: false

      t.timestamps
    end

    create_table :visit_resource_requirements do |t|
      t.references :visit_type, foreign_key: true
      t.string :provider_role, null: false
      t.integer :duration, null: false
      t.integer :offset, default: 0
      t.boolean :in_home, null: false

      t.timestamps
    end

    # migrate future visits to have visit resources
    now = Time.zone.now
    Visit.includes(:visit_resources).where("start_time > ?", now).each do |visit|
      next unless visit.visit_resources.blank?
      VisitResource.create(visit_id: visit.id,
                           field_provider_id: visit.field_provider_id,
                           start_time: visit.start_time,
                           end_time: visit.end_time,
                           in_home: true)
    end
  end
end
