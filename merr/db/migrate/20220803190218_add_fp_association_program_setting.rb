# frozen_string_literal: true

class AddFpAssociationProgramSetting < ActiveRecord::Migration[6.1]
  def change
    add_column :programs, :use_fp_pt_association, :boolean, default: false
  end
end
