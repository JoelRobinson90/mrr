# frozen_string_literal: true

class AddVisitToVisitRequests < ActiveRecord::Migration[6.1]
  def change
    add_reference :visits, :visit_request, null: true, foreign_key: true
  end
end
