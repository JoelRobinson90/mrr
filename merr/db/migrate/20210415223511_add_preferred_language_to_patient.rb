# typed: false
class AddPreferredLanguageToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :preferred_language, :string
  end
end
