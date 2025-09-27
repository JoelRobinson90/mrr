class AddAthenaTelehealthUrlToVisits < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :athena_telehealth_url, :string
  end
end
