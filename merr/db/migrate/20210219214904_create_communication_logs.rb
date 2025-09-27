# typed: true
class CreateCommunicationLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :communication_logs do |t|
      t.string :communication_type
      t.text :body
      t.string :subject
      t.string :destination
      t.string :sender
      t.string :event_trigger
      t.string :category
      t.references :patient, null: false, foreign_key: true
      t.references :context, polymorphic: true
      t.string :direction, null: false, default: "outbound"
      t.string :reciept

      t.timestamps
    end
  end
end
