# frozen_string_literal: true

class BackfillContactEmail < ActiveRecord::Migration[6.1]
  def up
    User.includes(:account).where(account_type: "Patient").each do |user|
      user.account&.update_columns(contact_email: user.email)
    end
  end

  def down
  end
end
