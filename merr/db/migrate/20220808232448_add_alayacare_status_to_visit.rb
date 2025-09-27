class AddAlayacareStatusToVisit < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :alayacare_status, :string
  end
end
