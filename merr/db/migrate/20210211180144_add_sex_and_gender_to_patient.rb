# typed: false
class AddSexAndGenderToPatient < ActiveRecord::Migration[6.0]
  def change
    add_column :patients, :sex, :string
    add_column :patients, :gender, :string
  end
end
