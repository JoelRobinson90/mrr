# == Schema Information
#
# Table name: cancel_codes
#
#  id           :bigint           not null, primary key
#  code         :string           not null
#  description  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  alayacare_id :integer
#  athena_id    :integer
#  ma_id        :string           indexed
#
# Indexes
#
#  index_cancel_codes_on_ma_id  (ma_id)
#
require 'rails_helper'

RSpec.describe CancelCode, type: :model do
  describe "scopes" do
    let!(:code_v1) { create :cancel_code, alayacare_id: '123', athena_id: nil }
    let!(:code_v2) { create :cancel_code, alayacare_id: nil, athena_id: '456' }
    let!(:code_both) { create :cancel_code, alayacare_id: '879', athena_id: '0ab' }

    describe "v1" do
      it "returns cancel codes with alayacare IDs" do
        v1_code_ids = CancelCode.v1.pluck(:id)
        expect(v1_code_ids).to include code_v1.id
        expect(v1_code_ids).not_to include code_v2.id
        expect(v1_code_ids).to include code_both.id
      end
    end

    describe "v2" do
      it "returns cancel codes with athena IDs" do
        v2_code_ids = CancelCode.v2.pluck(:id)
        expect(v2_code_ids).not_to include code_v1.id
        expect(v2_code_ids).to include code_v2.id
        expect(v2_code_ids).to include code_both.id
      end
    end
  end
end
