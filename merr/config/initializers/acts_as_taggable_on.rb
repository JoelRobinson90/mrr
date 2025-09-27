# typed: true
# frozen_string_literal: true

#
# Table tags
# ["id", "name", "created_at", "updated_at", "taggings_count"]

module ActsAsTaggableOn
  class Tag
    acts_as_paranoid
    # Monkey Patch in papertrail on tags
    has_paper_trail

    # Monkey Patch to allow for events to trigger on tags
    include ChangeEventTracker

    # Stream name required for Events
    def stream_name
      "#{self.class.name}$#{id}"
    end
  end
end
