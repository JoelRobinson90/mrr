# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe "GraphQL / Alayacare Update Visit", type: :request do
  before do
    sign_in current_user
  end

  let(:field_provider) { create :field_provider }
  let(:patient) { create :patient }

  let(:visit) { create(:visit, patient: patient, field_provider: field_provider) }
  let!(:visit_resource) { create(:visit_resource, visit: visit, field_provider: field_provider, in_home: false) }

  let!(:scheduler_log) { SchedulerLog.create!(run_id: "run-id-321", patient: patient) }

  # logString is meant to be a *JSON STRING* generated in the back end and bounced back from the front end
  let(:log_string) do
    {
      best_drive_time:      12,
      blocked_shifts_count: 3,
      drive_score:          34,
      total_score:          56,
      id:                   "should-be-ignored",
      run_id:               "should-be-ignored-too"
    }.to_json
  end

  let(:query_variables) do
    {
      visitParams: {
        externalId:      visit.external_id,
        patientId:       patient.id.to_s,
        fieldProviderId: field_provider.external_id,
        startTime:       "2022-04-29T15:00:00.000Z",
        endTime:         "2022-04-29T16:00:00.000Z",
        resources:       [{
          resourceId: field_provider.external_id,
          startTime:  "2022-04-29T15:00:00.000Z",
          endTime:    "2022-04-29T16:00:00.000Z",
          inHome:     true
        }]
      },
      runId:       "run-id-321",
      logString:   log_string
    }
  end

  describe "updateVisitRequest mutation" do
    query = <<-GRAPHQL
      mutation ($visitParams: UpdateAlayacareVisitParams!, $runId: String, $logString: String) {
        alayacareUpdateVisit(input: {
          visitParams: $visitParams,
          runId: $runId,
          logString: $logString
        }) {
          visit {
            externalId
          }
          errors
        }
      }
    GRAPHQL

    context "with admin user" do
      let(:current_user) { create(:medarrive_admin_user) }

      it "updates visit and updates scheduler log" do
        expect do
          post_graphql_request(
            query:     query,
            variables: query_variables
          )
        end.to change { VisitResource.count }.by(0).and change { ProviderPreference.count }.by(1)

        body = get_graphql_response

        visit_id = body["data"]["alayacareUpdateVisit"]["visit"]["externalId"]
        visit = Visit.find_by(external_id: visit_id)

        expect(visit.patient.id).to eq patient.id
        expect(visit.field_provider.id).to eq field_provider.id

        resource = visit.visit_resources.first
        expect(resource.field_provider_id).to eq field_provider.id
        expect(resource.start_time).to eq visit.start_time
        expect(resource.in_home).to be true

        scheduler_log.reload
        expect(scheduler_log.run_id).to eq "run-id-321"
        expect(scheduler_log.visit.external_id).to eq visit_id.to_s
        expect(scheduler_log.best_drive_time).to eq 12
        expect(scheduler_log.blocked_shifts_count).to eq 3
        expect(scheduler_log.drive_score).to eq 34
        expect(scheduler_log.total_score).to eq 56

        expect(visit.patient.preferred_providers).to eq([field_provider])
      end
    end
  end
end
