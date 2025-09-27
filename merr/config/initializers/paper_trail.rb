# frozen_string_literal: true

# typed: true
PaperTrail.config.track_associations = true

PaperTrailScrapbook.configure do |config|
  config.format = :json
  config.recent_first = true
  config.whodunnit_class = WhoDunnit
  config.invalid_whodunnit = proc {|id| WhoDunnit.unknown_user id }
  config.unknown_whodunnit = "*MedArrive System*"
  config.time_format = '%A, %d %b %Y at %l:%M %p %z'
end
