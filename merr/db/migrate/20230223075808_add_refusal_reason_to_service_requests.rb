class AddRefusalReasonToServiceRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :service_requests, :refusal_reason, :string
  end
end
