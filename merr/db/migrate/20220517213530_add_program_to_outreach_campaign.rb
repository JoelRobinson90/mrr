# frozen_string_literal: true

class AddProgramToOutreachCampaign < ActiveRecord::Migration[6.1]
  def change
    add_reference :outreach_campaigns, :program, foreign_key: true
  end
end
