class CreateServiceGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :service_groups do |t|
      t.string :name
      t.integer :total_estimated_duration

      t.timestamps
    end
  end
end
