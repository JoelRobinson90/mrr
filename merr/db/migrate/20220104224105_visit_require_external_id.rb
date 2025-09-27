# frozen_string_literal: true

class VisitRequireExternalId < ActiveRecord::Migration[6.1]
  def up
    updated_count = 0
    Visit.all.each do |visit|
      visit.save!
      updated_count += 1
    end
    Rails.logger.debug { "#{updated_count} visits given/confirmed external ids" }

    add_index :visits, :external_id, unique: true
    change_column_null :visits, :external_id, false
  end

  def down
    change_column_null :visits, :external_id, false
    remove_index :visits, name: "index_visits_on_external_id"
  end
end
