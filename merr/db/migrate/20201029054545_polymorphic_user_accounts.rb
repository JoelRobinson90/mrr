# typed: false
class PolymorphicUserAccounts < ActiveRecord::Migration[6.0]
  def change
  	# remove old associations
  	remove_reference :providers, :user, foreign_key: true, index: true
  	remove_reference :clients, :user, foreign_key: true, index: true

  	# new polymorphic association
  	add_column :users, :account_id, :bigint
  	add_column :users, :account_type, :string
  	add_index :users, [:account_type, :account_id]
  end
end
