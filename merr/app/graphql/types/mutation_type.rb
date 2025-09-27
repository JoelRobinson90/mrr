# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :alayacare_update_visit, mutation: Mutations::AlayacareUpdateVisit
    field :cancel_visit, mutation: Mutations::CancelVisit
    field :create_alayacare_visit, mutation: Mutations::CreateAlayacareVisit
    field :create_alayacare_visit_note, mutation: Mutations::CreateAlayacareVisitNote
    field :create_patient, mutation: Mutations::CreatePatient
    field :create_visit_event, mutation: Mutations::CreateVisitEvent
    field :create_visit_group, mutation: Mutations::CreateVisitGroup
    field :create_visit_note, mutation: Mutations::CreateVisitNote
    field :create_visit_request, mutation: Mutations::CreateVisitRequest
    field :import_outreach_campaign_contacts, mutation: Mutations::ImportOutreachCampaignContacts
    field :reschedule_visit, mutation: Mutations::RescheduleVisit
    field :update_outreach_campaign_activity, mutation: Mutations::UpdateOutreachCampaignActivity
    field :update_service_request, mutation: Mutations::UpdateServiceRequest
  end
end
