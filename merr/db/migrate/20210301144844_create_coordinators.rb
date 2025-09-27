# typed: true
class CreateCoordinators < ActiveRecord::Migration[6.0]
  def change
    create_table :coordinators do |t|
      t.string :first_name
      t.string :last_name
      t.references :demand_partner, null: false, foreign_key: true
    end
  end
end
