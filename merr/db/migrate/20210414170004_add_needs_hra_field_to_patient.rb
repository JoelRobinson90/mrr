# typed: false
class AddNeedsHraFieldToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :needs_hra_survey, :boolean
  end
end
