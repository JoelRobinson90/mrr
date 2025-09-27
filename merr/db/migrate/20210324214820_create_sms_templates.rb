# typed: false
class CreateSmsTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :sms_templates do |t|
      t.references :demand_partner, null: false, foreign_key: true, on_delete: :cascade
      t.string :message_type, null: false
      t.string :message_body, null: false

      t.timestamps
    end
  end
end
