class AddShiftAbbrevFieldsToPrograms < ActiveRecord::Migration[6.1]
  def change
    add_column :programs, :min_shift_length_in_hours, :float, default: 8
    add_column :programs, :shift_abbrev_notify_in_days, :integer, default: 2
  end
end
