# frozen_string_literal: true

class AddCreateLocalVisitToVisitOptimizerSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :visit_optimizer_settings, :create_local_visit, :boolean, default: false
  end
end
