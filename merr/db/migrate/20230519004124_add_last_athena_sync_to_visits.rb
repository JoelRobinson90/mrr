class AddLastAthenaSyncToVisits < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :last_athena_sync, :string
  end
end
