# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: sms_templates
#
#  id                :bigint           not null, primary key
#  message_body      :string           not null
#  message_type      :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_partner_id :bigint           not null, indexed
#
# Indexes
#
#  index_sms_templates_on_demand_partner_id  (demand_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
require "rails_helper"

RSpec.describe SmsTemplate, type: :model do
  describe "performs validations" do
    let(:demand_partner) { create(:demand_partner) }

    it "succeeds with correctly formatted tags" do
      template = SmsTemplate.create(message_body: "Test %{first_name}", message_type: "confirmation",
                                    demand_partner: demand_partner)

      expect(template.persisted?).to be true
    end

    it "fails with incorrect tags" do
      template = SmsTemplate.create(message_body: "Test {first_name}", message_type: "confirmation",
                                    demand_partner: demand_partner)

      expect(template.persisted?).to be false
      expect(template.errors.full_messages.to_sentence).to eq("Message body Can't have a curly bracket without %")
    end

    context "with multiple demand partners" do
      let(:demand_partner2) { create(:demand_partner) }
      it "enforces uniqueness" do
        template = SmsTemplate.create(message_body: "Test %{first_name}", message_type: "confirmation",
                                      demand_partner: demand_partner)
        expect(template.persisted?).to be true

        template = SmsTemplate.create(message_body: "Test %{first_name}", message_type: "confirmation",
                                      demand_partner: demand_partner2)
        expect(template.persisted?).to be true

        template = SmsTemplate.create(message_body: "Test %{first_name}", message_type: "reminder",
                                      demand_partner: demand_partner)
        expect(template.persisted?).to be true

        non_unique_template = SmsTemplate.create(message_body:   "Other",
                                                 message_type:   "confirmation",
                                                 demand_partner: demand_partner)

        expect(non_unique_template.persisted?).to be false
        expect(non_unique_template.errors.full_messages.to_sentence).to eq("Message type has already been taken")
      end
    end
  end
end
