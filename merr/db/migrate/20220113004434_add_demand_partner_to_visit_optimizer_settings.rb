# frozen_string_literal: true

class AddDemandPartnerToVisitOptimizerSettings < ActiveRecord::Migration[6.1]
  def change
    add_reference :visit_optimizer_settings, :demand_partner, null: false, foreign_key: true
  end
end
