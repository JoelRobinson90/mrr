class AddMoreAthenaIds < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :athena_id, :integer
    add_column :demand_partners, :athena_id, :integer
    add_column :cancel_codes, :athena_id, :integer

    change_column_null :cancel_codes, :alayacare_id, true
    change_column_null :visit_types, :alayacare_id, true
    change_column_null :services, :alayacare_id, true
  end
end
