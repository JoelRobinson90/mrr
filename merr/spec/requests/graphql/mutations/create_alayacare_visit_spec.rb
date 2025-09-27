# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe "GraphQL / Create Alayacare Visit", type: :request do
  before do
    sign_in current_user
  end

  let(:demand_partner) { create :demand_partner }
  let(:field_provider) { create :field_provider }
  let(:program) { create :program, demand_partner: demand_partner, visit_types: [visit_type] }
  let(:patient) { create :patient, demand_partner: demand_partner, programs: [program] }
  let(:visit_type) { create :visit_type }
  let(:service) { create :service }

  let!(:scheduler_log) { SchedulerLog.create!(run_id: "run-id-123", patient: patient) }

  # logString is meant to be a *JSON STRING* generated in the back end and bounced back from the front end
  let(:log_string) do
    {
      best_drive_time:                                              12,
      blocked_shifts_count:                                         3,
      drive_score:                                                  34,
      total_score:                                                  56,
      id:                                                           "should-be-ignored",
      run_id:                                                       "should-be-ignored-too",
      other_field_that_graphql_will_accept_but_doesnt_really_exist: "ignore-me"
    }.to_json
  end

  let(:query_variables) do
    {
      visitParams: {
        patientId:               patient.id,
        fieldProviderExternalId: field_provider.external_id,
        programId:               program.id,
        visitTypeId:             visit_type.id,
        serviceIds:              [service.id],
        startTime:               "2022-04-29T15:00:00.000Z",
        endTime:                 "2022-04-29T16:00:00.000Z",
        resources:               [{
          resourceId: field_provider.external_id,
          startTime:  "2022-04-29T15:00:00.000Z",
          endTime:    "2022-04-29T16:00:00.000Z",
          inHome:     true
        }]
      },
      runId:       "run-id-123",
      logString:   log_string
    }
  end

  describe "createVisitRequest mutation" do
    query = <<-GRAPHQL
      mutation ($visitParams: CreateAlayacareVisitParams!, $runId: String, $logString: String) {
        createAlayacareVisit(input: {
          visitParams: $visitParams,
          runId: $runId,
          logString: $logString
        }) {
          visitId
          errors
        }
      }
    GRAPHQL

    context "with admin user" do
      let(:current_user) { create(:medarrive_admin_user) }

      it "creates a new visit and updates scheduler log" do
        expect do
          post_graphql_request(
            query:     query,
            variables: query_variables
          )
        end.to change { Visit.count }.by(1).and change { ProviderPreference.count }.by(1)
        body = get_graphql_response

        visit_id = body["data"]["createAlayacareVisit"]["visitId"]
        visit = Visit.find(visit_id)

        expect(visit.patient.id).to eq patient.id
        expect(visit.field_provider.id).to eq field_provider.id
        expect(visit.program.id).to eq program.id
        expect(visit.visit_type.id).to eq visit_type.id
        expect(visit.service_ids).to eq [service.id]

        resource = visit.visit_resources.first
        expect(resource.field_provider_id).to eq field_provider.id
        expect(resource.start_time).to eq visit.start_time
        expect(resource.in_home).to be true

        scheduler_log.reload
        expect(scheduler_log.run_id).to eq "run-id-123"
        expect(scheduler_log.visit.id.to_s).to eq visit_id.to_s
        expect(scheduler_log.best_drive_time).to eq 12
        expect(scheduler_log.blocked_shifts_count).to eq 3
        expect(scheduler_log.drive_score).to eq 34
        expect(scheduler_log.total_score).to eq 56
        expect(scheduler_log.full_preferred_provider_option_chosen).to be false
        expect(scheduler_log.partial_preferred_provider_option_chosen).to be false

        expect(visit.patient.preferred_providers).to eq([field_provider])
      end

      context "with existing provider preference" do
        let(:visit_type) do
          build(:visit_type,
                visit_resource_requirements: [build(:visit_resource_requirement, provider_role: "field_provider"),
                                              build(:visit_resource_requirement, provider_role: "social_worker")])
        end
        let(:existing_field_provider) { create(:field_provider, role: field_provider.role) }
        let!(:provider_preference) do
          create(:provider_preference, patient: patient, field_provider: existing_field_provider)
        end
        let(:instance) { Mutations::AlayacareBaseMutation.new(object: nil, context: nil, field: nil) }

        it "finds existing preferred provider" do
          result = nil
          visit_resources = [
            {resource_id: existing_field_provider.external_id}
          ]

          expect do
            result = instance.update_preferred_providers(patient, visit_resources, visit_type)
          end.to change { ProviderPreference.count }.by(0)

          expected = {
            full_preferred_provider_option_chosen:    true,
            partial_preferred_provider_option_chosen: true
          }

          expect(result).to eq(expected)
        end

        it "doesn't overwrite existing preference if role is the same" do
          result = nil
          visit_resources = [
            {resource_id: field_provider.external_id}
          ]

          expect do
            result = instance.update_preferred_providers(patient, visit_resources, visit_type)
          end.to change { ProviderPreference.count }.by(0)

          expected = {
            full_preferred_provider_option_chosen:    false,
            partial_preferred_provider_option_chosen: false
          }

          expect(result).to eq(expected)
        end

        it "creates new preference if role is different" do
          field_provider.update(role: "social_worker")

          result = nil
          visit_resources = [
            {resource_id: existing_field_provider.external_id},
            {resource_id: field_provider.external_id}
          ]

          expect do
            result = instance.update_preferred_providers(patient, visit_resources, visit_type)
          end.to change { ProviderPreference.count }.by(1)

          expected = {
            full_preferred_provider_option_chosen:    false,
            partial_preferred_provider_option_chosen: true
          }

          expect(result).to eq(expected)

          patient.reload
          expect(patient.preferred_providers).to match_array([field_provider, existing_field_provider])
        end
      end

      context "with malformed scheduler log JSON" do
        let(:log_string) { "this is not json" }

        it "does not block creating the visit" do
          expect do
            post_graphql_request(
              query:     query,
              variables: query_variables
            )
          end.to change { Visit.count }.by(1)
          body = get_graphql_response

          visit_id = body["data"]["createAlayacareVisit"]["visitId"]
          visit = Visit.find(visit_id)
          expect(visit.patient.id).to eq patient.id

          scheduler_log.reload
          expect(scheduler_log.visit.id.to_s).to eq visit_id.to_s
          expect(scheduler_log.best_drive_time).to be_nil
        end
      end
    end

    context "with demand coordinator user" do
      let(:current_user) { create(:demand_coordinator_user) }

      it "does not create a new visit" do
        expect do
          post_graphql_request(
            query:     query,
            variables: query_variables
          )
        end.not_to change { Visit.count }
        body = get_graphql_response

        expect(body["data"]["createAlayacareVisit"]["visitId"]).to be_nil
      end
    end
  end
end
