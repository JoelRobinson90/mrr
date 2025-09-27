# frozen_string_literal: true

class CreateJoinTablesForServices < ActiveRecord::Migration[6.1]
  def change
    create_table :visit_services do |t|
      t.references :visit, index: false
      t.references :service, index: false
      t.timestamps
      # fast accessing of services for a visit or visits for a service
      t.index %i[visit_id service_id]
      t.index %i[service_id visit_id]
    end

    create_table :program_services do |t|
      t.references :program, index: false
      t.references :service, index: false
      t.timestamps
      # fast accessing of services for a given program
      t.index %i[program_id service_id]
    end

    create_table :visit_type_services do |t|
      t.references :visit_type, index: false
      t.references :service, index: false
      t.timestamps
      # fast accessing of services for a given visit type
      t.index %i[visit_type_id service_id]
    end
  end
end
