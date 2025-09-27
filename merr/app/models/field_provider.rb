# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: field_providers
#
#  id                      :bigint           not null, primary key
#  bio                     :string
#  date_of_birth           :date
#  first_name              :string
#  last_name               :string
#  license_number          :string
#  phone                   :string
#  provider_level          :string
#  push_to_wheniwork_error :string
#  role                    :string           default("field_provider")
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  athena_id               :integer
#  external_id             :string           not null, indexed
#  field_org_id            :bigint           not null, indexed
#  ma_id                   :string           indexed
#
# Indexes
#
#  index_field_providers_on_external_id   (external_id) UNIQUE
#  index_field_providers_on_field_org_id  (field_org_id)
#  index_field_providers_on_ma_id         (ma_id)
#
# Foreign Keys
#
#  fk_rails_...  (field_org_id => field_orgs.id)
#
class FieldProvider < ApplicationRecord
  include OptionalPhysicalAddress
  include UserAccount
  include FieldAccount
  include ExternalId
  include PushToExternal
  include PushToSalesforce

  has_one_attached :avatar
  has_many :appointments
  has_many :visits
  has_many :work_sessions

  ROLES = %w[field_provider social_worker nurse_practitioner witness].freeze

  validates :role, inclusion: {in: ROLES}, allow_blank: false

  # Paper trail story association
  def trailed_related_content
    [address] | work_sessions
  end

  def to_builder
    Jbuilder.new do |provider|
      provider.call(self, :id, :first_name, :date_of_birth, :last_name, :bio, :phone, :provider_level, :created_at, :updated_at,
                    :display_name)
      provider.email provider.email
    end
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def phone_number
    phone
  end

  def to_s
    full_name
  end

  def session_timeout_in
    15.minutes
  end

  def skip_alayacare_sync?
    user.nil? || user.skip_alayacare_sync
  end

  def push_to_alayacare(mode)
    Alayacare::FieldProviderCreateOrUpdateService.call(mode, self)
  end

  def push_to_wheniwork(mode)
    WhenIWork::PushFieldProvider.call(mode, self)
  end

  def should_push_to_salesforce?
    ma_id?
  end

  def to_ma_object
    fields = %i[first_name last_name phone_number email]
    make_ma_object(fields, associations = [:field_org])
  end
end
