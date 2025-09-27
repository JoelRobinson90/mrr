# typed: false
class MakeAddressesPolymorphic < ActiveRecord::Migration[6.0]
  def up
    add_reference :addresses, :addressable, null: false,
      polymorphic: true,
      index: true

    remove_reference :addresses, :client
    remove_reference :addresses, :field_provider

    remove_reference :appointments, :address
    remove_reference :field_orgs, :address
  end

  def down
    remove_reference :addresses, :addressable, polymorphic: true

    add_reference :addresses, :client, null: true, foreign_key: {on_delete: :cascade}
    add_reference :addresses, :field_provider, null: true, index: true, foreign_key: {on_delete: :cascade}

    add_reference :appointments, :address, null: true, foreign_key: true
    add_reference :field_orgs, :address, null: true, foreign_key: true
  end
end
