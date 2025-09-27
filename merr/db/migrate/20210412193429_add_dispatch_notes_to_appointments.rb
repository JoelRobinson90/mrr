# typed: false
class AddDispatchNotesToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :dispatch_notes, :text
  end
end
