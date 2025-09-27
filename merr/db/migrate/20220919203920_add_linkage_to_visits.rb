class AddLinkageToVisits < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :original_visit_id, :integer, null: true, index: true
    add_column :visits, :next_linked_visit_id, :integer, null: true, index: true
    add_column :visits, :previous_linked_visit_id, :integer, null: true, index: true

    add_foreign_key :visits, :visits, column: :original_visit_id
    add_foreign_key :visits, :visits, column: :next_linked_visit_id
    add_foreign_key :visits, :visits, column: :previous_linked_visit_id

    add_column :visits, :reschedule_count, :integer, index: true
  end
end
