# typed: false
class AddAddressToFieldProvider < ActiveRecord::Migration[6.0]
  def change
  	# remove previous reference
  	remove_reference :field_providers, :address, index: true, foreign_key: true

  	# now client_id or field_provider_id must be null
  	change_column_null :addresses, :client_id, true

  	# add new reference
  	add_reference :addresses, :field_provider, null: true, index: true, foreign_key: {on_delete: :cascade}
  end
end
