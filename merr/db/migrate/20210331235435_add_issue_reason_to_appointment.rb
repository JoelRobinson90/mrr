# typed: false
class AddIssueReasonToAppointment < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :issue_reason, :string
  end
end
