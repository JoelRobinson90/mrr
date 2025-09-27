# frozen_string_literal: true

class AddDispositionToSchedulerLog < ActiveRecord::Migration[6.1]
  def change
    add_column :scheduler_logs, :disposition, :string
    add_column :scheduler_logs, :blocking_roles, :string
    add_column :scheduler_logs, :shifts_count_by_role, :string
    add_column :scheduler_logs, :pre_merge_slots_count_by_role, :string
  end
end
