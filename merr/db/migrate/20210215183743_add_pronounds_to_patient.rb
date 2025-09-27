# typed: false
class AddPronoundsToPatient < ActiveRecord::Migration[6.0]
  def change
    add_column :patients, :preferred_pronouns, :string
  end
end
