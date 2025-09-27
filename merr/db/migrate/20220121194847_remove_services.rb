# frozen_string_literal: true

class RemoveServices < ActiveRecord::Migration[6.1]
  def change
    up_only { nuke_existing_service_versions }

    drop_table :service_groups_services do |t|
      t.references :service, null: false, foreign_key: true
      t.references :service_group, null: false, foreign_key: true
      t.integer :order, null: false, default: 0

      t.timestamps
    end

    drop_table :service_groups, force: :cascade do |t|
      t.string :name
      t.integer :total_estimated_duration
      t.timestamps
    end

    drop_join_table :appointments, :services do |t|
      t.index %i[appointment_id service_id]
      t.index %i[service_id appointment_id]
    end

    drop_table :services do |t|
      t.string :name, null: false
      t.string :description
      t.integer :estimated_duration, null: false, default: 0
      t.string :category, null: false

      t.timestamps
    end
  end

  def nuke_existing_service_versions
    versions = PaperTrail::Version.where(item_type: %w[Service AppointmentsService ServiceGroup ServicesServiceGroup])

    PaperTrail::VersionAssociation.where(version_id: versions.pluck(:id)).delete_all

    versions.delete_all
  end
end
