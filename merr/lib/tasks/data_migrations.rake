# namespace :data do
#   task :migrations do
#     Rake.application.in_namespace(:data) do |namespace|
#       namespace.tasks.each do |t|
#         next if t.name == "data:migrations"
#         puts "Invoking #{t.name}:"
#         t.invoke
#       end
#     end
#   end

#   task backfill_visit_resources: :environment do
#     puts "Adding visit resources to future visits"
#     now = Time.zone.now

#     Visit.includes(:visit_resources).where("start_time > ?", now).each do |visit|
#       next unless visit.visit_resources.blank?
#       VisitResource.create(visit_id: visit.id,
#                            field_provider_id: visit.field_provider_id,
#                            start_time: visit.start_time,
#                            end_time: visit.end_time,
#                            in_home: true)
#     end
#     puts "Backfill complete"
#   end
# end