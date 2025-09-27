# frozen_string_literal: true

class CreateExternalUserAccountType < ActiveRecord::Migration[6.1]
  def change
    create_table :external_accounts do |t|
      t.string "first_name"
      t.string "last_name"

      t.references :demand_partner, foreign_key: true

      t.timestamps
    end

    create_table :ext_acct_programs do |t|
      t.references :external_account, index: false
      t.references :program, index: false
      t.timestamps

      t.index %i[external_account_id program_id]
      t.index %i[program_id external_account_id]
    end
  end
end
