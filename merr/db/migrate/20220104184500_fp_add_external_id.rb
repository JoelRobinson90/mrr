# frozen_string_literal: true

class FpAddExternalId < ActiveRecord::Migration[6.1]
  def up
    add_column :field_providers, :external_id, :string

    updated_count = 0
    FieldProvider.all.each do |fp|
      fp.save!
      updated_count += 1
    end
    Rails.logger.debug { "#{updated_count} field providers given external ids" }

    add_index :field_providers, :external_id, unique: true
    change_column_null :field_providers, :external_id, false
  end

  def down
    remove_column :field_providers, :external_id
  end
end
