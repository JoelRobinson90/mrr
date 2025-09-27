# frozen_string_literal: true

# == Schema Information
#
# Table name: programs
#
#  id                                  :bigint           not null, primary key
#  active                              :boolean          default(TRUE)
#  arrival_window_block_schedule       :string
#  arrival_window_offset_minutes       :integer
#  drive_time_breakpoints              :string
#  drive_weight                        :integer          default(80), not null
#  enforce_service_area                :boolean          default(FALSE)
#  high_rank_absolute_threshold        :integer          default(90)
#  high_rank_percentile_threshold      :integer          default(90)
#  hours_before_first_option           :integer          default(10), not null
#  max_grace_period                    :integer          default(0)
#  max_results                         :integer
#  max_straight_line_distance_in_miles :integer          default(300), not null
#  medium_rank_absolute_threshold      :integer          default(60)
#  medium_rank_percentile_threshold    :integer          default(60)
#  min_shift_length_in_hours           :float            default(8.0)
#  minutes_of_buffer_time              :integer          default(15), not null
#  name                                :string           not null
#  proximity_weight                    :integer          default(10), not null
#  shift_abbrev_notify_in_days         :integer          default(2)
#  shift_shortening_penalty_weight     :integer          default(0)
#  use_fp_pt_association               :boolean          default(FALSE)
#  utilization_weight                  :integer          default(10), not null
#  v2                                  :boolean          default(FALSE)
#  virtual_provider_offset             :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  alayacare_service_code_id           :string           not null
#  demand_partner_id                   :bigint           not null, indexed
#  ma_id                               :string           indexed
#
# Indexes
#
#  index_programs_on_demand_partner_id  (demand_partner_id)
#  index_programs_on_ma_id              (ma_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
require "rails_helper"

RSpec.describe Program, type: :model do
  context "during validation" do
    let(:program) { FactoryBot.build(:program, name: "test") }

    it "checks drive_time_breakpoints" do
      # expect(program.valid?).to be true

      # program.drive_time_breakpoints = "[]"
      # expect(program.valid?).to be true

      # program.drive_time_breakpoints = '[{"drive": 5, "score": 5},{"drive": 10, "score": 10}]'
      # expect(program.valid?).to be true

      program.drive_time_breakpoints = '[{"bad": "data"}]'
      expect(program.valid?).to be false
      expect(program.errors.full_messages[0]).to eq('Drive time breakpoints are not in the valid format [{"drive": 10, "score": 10}]')

      program.drive_time_breakpoints = '{"drive": 5, "score": 5}'
      expect(program.valid?).to be false
      expect(program.errors.full_messages[0]).to eq("Drive time breakpoints could not be parsed: not an array")

      program.drive_time_breakpoints = "asdf"
      expect(program.valid?).to be false
      expect(program.errors.full_messages[0].include?("unexpected token")).to be true

      program.drive_time_breakpoints = '[{"drive": 5, "score": 110}]'
      expect(program.valid?).to be false
      expect(program.errors.full_messages[0]).to eq("Drive time breakpoints contains invalid drive or score value")
    end
  end
end
