# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::BackfillVisits do
  let(:service) { Alayacare::BackfillVisits }

  describe "backfill visit" do
    context "with visit id" do
      let(:date) { Date.parse("2022-08-10") }
      let(:orphaned_visit_date) { Date.parse("2022-08-08") }
      let(:pending_job) do
        create(:background_job_result, label: "Backfill test", status: "pending",
                                 job_type: "backfill_alayacare_data")
      end

      let!(:dp) { create(:demand_partner, name: "Molina") }
      let!(:visit_type) { create(:visit_type, name: "Molina Door to Door", alayacare_id: 7) }
      let!(:program) { create(:program, name: "test program", visit_types: [visit_type]) }

      it "should create visit and patient and field provider" do
        result = service.call(pending_job.id, dry_run: false, start_date: date, end_date: date)
        expect(result.success?).to be true

        msg = "Finished.  Total: 1, Created: 1, Matched: 0, Updated: 0, skipped: 0 | ID updated in MA: 1, ID updated in AC: 0 | error count: 0"
        expect(result.message).to eq(msg)

        visit = Visit.last
        expect(visit.field_provider.first_name).to eq("Test")
        expect(visit.patient.first_name).to eq("Bryaan")
        expect(visit.patient.address.address_line_one).to eq("730 New Washburb Way")

        # Test idempotent
        visit.update(alayacare_status: "new")
        result = service.call(pending_job.id, dry_run: false, start_date: date, end_date: date)
        expect(result.success?).to be true
        msg = "Finished.  Total: 1, Created: 0, Matched: 1, Updated: 0, skipped: 0 | ID updated in MA: 0, ID updated in AC: 0 | error count: 0"
        expect(result.message).to eq(msg)
        visit.reload
        expect(visit.alayacare_status).to eq "missed"

        # Test updates
        old_start = visit.start_time
        visit.update(start_time: old_start + 15.minutes)
        result = service.call(pending_job.id, dry_run: false, start_date: date, end_date: date)
        expect(result.success?).to be true
        msg = "Finished.  Total: 1, Created: 0, Matched: 0, Updated: 1, skipped: 0 | ID updated in MA: 0, ID updated in AC: 0 | error count: 0"
        expect(result.message).to eq(msg)
        visit.reload
        expect(visit.start_time).to eq old_start
      end

      it "should update ID in alayacare" do
        # This day has a visit that was created in AC and has no external id
        result = service.call(pending_job.id, dry_run: false, start_date: orphaned_visit_date, end_date: orphaned_visit_date)
        expect(result.success?).to be true

        msg = "Finished.  Total: 1, Created: 1, Matched: 0, Updated: 0, skipped: 0 | ID updated in MA: 0, ID updated in AC: 1 | error count: 0"
        expect(result.message).to eq(msg)
      end

      it "should skip unassigned visits" do
        date = Date.parse("2022-05-04")

        result = service.call(pending_job.id, dry_run: false, start_date: date, end_date: date)
        expect(result.success?).to be true

        msg = "Finished.  Total: 1, Created: 0, Matched: 0, Updated: 0, skipped: 1 | ID updated in MA: 0, ID updated in AC: 0 | error count: 0"
        expect(result.message).to eq(msg)
      end
    end
  end
end
