# frozen_string_literal: true

# typed: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Rails.env.development?

  temp_external_push_setting = ENV["ENABLE_PUSH_TO_EXTERNAL"]&.to_s
  ENV["ENABLE_PUSH_TO_EXTERNAL"] = "false"
  p "SEEDING DB..."

  result = Alayacare::DemandPartnerIdSyncService.call()
  p "Demand Partner sync: Updated AlayaCare IDs for: #{result[:matched_groups]} ----- Found in AlayaCare but not MedArrive: #{result[:unmatched_groups]}"

  result = Alayacare::PullExternalData.call(CancelCode, "scheduler/cancelcodes", :code)
  if result.success?
    p "Synced cancel codes"
  else
    p "CancelCode sync failed:"
    p result.error
  end

  result = Alayacare::PullExternalData.call(Service, "scheduler/services/forms", :name)
  if result.success?
    p "Synced services"
  else
    p "Service sync failed: #{result.error}"
    p result.error
  end

  result = Alayacare::PullExternalData.call(VisitType, "scheduler/service_codes", :name)
  if result.success?
    p "Synced visit types"
  else
    p "VisitType sync failed: #{result.error}"
    p result.error
  end

  # create default program
  default_program = Program.find_or_create_by(name: "Default program",
                                              demand_partner: DemandPartner.first,
                                              alayacare_service_code_id: "")
  VisitType.all.each do |visit_type|
    if visit_type.programs.length == 0
      visit_type.programs << default_program
      visit_type.save
    end
  end

  result = Routing::GetFieldProviders.call
  if result.success?
    p "Synced field providers"
  else
    p "FieldProvider sync failed: #{result.error}"
    p result.error
  end

  # Fetch some visits
  start_date = Date.today - 3.days
  end_date = Date.today + 7.days

  pending_job = BackgroundJobResult.create(
    label:    "Backfill visits seeding mode dates #{start_date} to #{end_date}",
    status:   "pending",
    job_type: "backfill_alayacare_data"
  )

  result = Alayacare::BackfillVisits.call(pending_job.id, dry_run: false,
                                          start_date: start_date, end_date: end_date)
  if result.success?
    p "Fetched visits from #{start_date} to #{end_date}"
  else
    p "Visit fetch failed: #{result.error}"
  end

  p "SEEDING COMPLETE"

  p "To create users, log in with Okta account."

  ENV["ENABLE_PUSH_TO_EXTERNAL"] = temp_external_push_setting
end
