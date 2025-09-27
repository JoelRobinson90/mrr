# frozen_string_literal: true

class CreateVisitRequestServices < ActiveRecord::Migration[6.1]
  def change
    create_table :visit_request_services do |t|
      t.references :visit_request, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.index [:visit_request_id, :service_id]
      t.index [:service_id, :visit_request_id]

      t.timestamps
    end
  end
end
