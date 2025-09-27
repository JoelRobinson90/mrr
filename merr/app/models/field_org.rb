# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: field_orgs
#
#  id         :bigint           not null, primary key
#  name       :string
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ma_id      :string           indexed
#
# Indexes
#
#  index_field_orgs_on_ma_id  (ma_id)
#
class FieldOrg < ApplicationRecord
  include OptionalPhysicalAddress
  include PushToSalesforce

  validates :name, :slug, presence: true
  validate :validate_slug_format, if: :slug_changed?

  before_validation :generate_slug

  has_one_attached :logo

  has_many :field_admins
  has_many :field_dispatchers
  has_many :field_providers

  SLUG_REGEX = /\A[a-z_]+\z/.freeze

  def validate_slug_format
    errors.add(:slug, "should only consist of lowercase letters and underscores") unless slug =~ SLUG_REGEX
  end

  def generate_slug
    self.slug ||= name.parameterize(separator: "_")
  end

  def to_s
    name
  end

  def should_push_to_salesforce?
    ma_id?
  end

  def to_ma_object
    make_ma_object([:name])
  end
end
