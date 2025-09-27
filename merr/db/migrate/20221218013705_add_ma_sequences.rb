class AddMaSequences < ActiveRecord::Migration[6.1]
  def up
    create_sequence :patient_ma_id
    create_sequence :visit_ma_id
    create_sequence :field_provider_ma_id
  end

  def down
    drop_sequence :patient_ma_id
    drop_sequence :visit_ma_id
    drop_sequence :field_provider_ma_id
  end
end
