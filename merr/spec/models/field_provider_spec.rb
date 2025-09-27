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
require "rails_helper"

RSpec.describe FieldProvider, type: :model do
  context "before validation" do
    let(:field_provider) { FactoryBot.build(:field_provider, external_id: nil) }

    it "generates external_id" do
      expect(field_provider.valid?).to be true

      expect(field_provider.external_id.length).to eq(13 + 1 + 16) # 13 for FieldProvider, 1 for underscore, 16 for hash
      expect(field_provider.external_id.starts_with?("FieldProvider_")).to be true
    end
  end

  context "after validation" do
    let(:field_provider) { FactoryBot.create(:field_provider) }

    after(:each) do
      ENV["ENABLE_PUSH_TO_EXTERNAL"] = "false"
    end

    it "updates correctly" do
      expect(field_provider).to receive(:push_to_external).and_call_original
      # expect(field_provider).to receive(:push_to_alayacare)

      ENV["ENABLE_PUSH_TO_EXTERNAL"] = "true"

      field_provider.first_name = "Nova"
      # existing id on WiW.
      field_provider.external_id = "34t45g45"
      # should try to update, fail, and then create on alayacare.
      # WiW will always upsert based on if id exists externally.
      field_provider.save!
      field_provider.reload

      expect(field_provider.valid?).to be true
      expect(field_provider.first_name).to eq("Nova")
    end
  end
end
