class AddVisitConfirmedDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :visits, :confirmed, false
  end
end
