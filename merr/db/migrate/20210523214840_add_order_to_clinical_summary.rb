# typed: false
class AddOrderToClinicalSummary < ActiveRecord::Migration[6.1]
  def change
    add_reference :redox_clinical_summaries, :order, null: true, foreign_key: true
  end
end
