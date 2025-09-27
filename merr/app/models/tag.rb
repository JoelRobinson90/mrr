# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  color          :string           default("#FFF"), not null
#  deleted_at     :datetime         indexed
#  description    :string
#  group          :string           default("Appointment"), not null
#  name           :string           indexed
#  taggings_count :integer          default(0)
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_tags_on_deleted_at  (deleted_at)
#  index_tags_on_name        (name) UNIQUE
#

# < ActsAsTaggableOn::Tag
class Tag < ApplicationRecord
  acts_as_paranoid
  # Monkey Patch in papertrail on tags
  has_paper_trail

  # Monkey Patch to allow for events to trigger on tags
  include ChangeEventTracker

  # TODO: Set group based on the object that is saving it
  validates :group, inclusion: {in: %w[Appointment Patient]}
  validates :name, presence: true, uniqueness: {scope: :group}
  validates :color, length: {in: 4..7}
  validate :color_starts_with_hash

  has_many :taggings, dependent: :destroy, class_name: '::ActsAsTaggableOn::Tagging'

  # Stream name required for Events
  def stream_name
    "#{self.class.name}$#{id}"
  end

  private

  def color_starts_with_hash
    errors.add(:color, "Invalid format. Use #FFF or #FFFFFF.") unless color.start_with?("#")
  end
end
