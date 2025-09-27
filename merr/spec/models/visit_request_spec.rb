# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_requests
#
#  id           :bigint           not null, primary key
#  cancelled_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :bigint           not null, indexed
#  patient_id   :bigint           not null, indexed
#  program_id   :bigint           not null, indexed
#
# Indexes
#
#  index_visit_requests_on_creator_id  (creator_id)
#  index_visit_requests_on_patient_id  (patient_id)
#  index_visit_requests_on_program_id  (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (program_id => programs.id)
#
require "rails_helper"

RSpec.describe VisitRequest, type: :model do
  describe "validations" do
    let(:demand_partner) { create :demand_partner }
    let(:program) { create :program, demand_partner: demand_partner }
    let(:other_program) { create :program }
    let(:patient) { create :patient, demand_partner: demand_partner }
    let(:other_patient) { create :patient }

    describe "match_patient_demand_partner" do
      it "is valid if the patient demand partner matches the program demand partner" do
        record = build :visit_request, program: program, patient: patient
        expect(record).to be_valid
      end

      it "invalidates the record if patient demand partner does not match program demand partner" do
        record = build :visit_request, program: program, patient: other_patient
        expect(record).not_to be_valid
        expect(record.errors[:patient].first).to include "does not belong to the program partner"
      end
    end
  end

  describe "#status" do
    it "is cancelled if the visit request has a cancelled_at timestamp" do
      record = build :visit_request, cancelled_at: 1.day.ago
      expect(record.status).to eq :cancelled
    end

    it "is pending if the visit request does not yet have a visit" do
      record = build :visit_request, cancelled_at: nil
      expect(record.status).to eq :pending
    end
  end
end
