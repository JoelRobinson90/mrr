class CreateServicesServiceGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :service_groups_services do |t|
      t.references :service, null: false, foreign_key: true
      t.references :service_group, null: false, foreign_key: true
      t.integer :order, null: false, default: 0

      t.timestamps
    end
  end
end
