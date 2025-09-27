class AddPushToAthenaErrorToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :push_to_athena_error, :string
  end
end
