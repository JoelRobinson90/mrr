class AddPatientRiskCategoryToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :primary_risk_category, :string
  end
end
