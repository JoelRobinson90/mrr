# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: communication_logs
#
#  id                 :bigint           not null, primary key
#  body               :text
#  category           :string
#  communication_type :string
#  context_type       :string           indexed => [context_id]
#  destination        :string
#  direction          :string           default("outbound"), not null
#  event_trigger      :string
#  reciept            :string
#  sender             :string
#  subject            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  context_id         :bigint           indexed => [context_type]
#  patient_id         :bigint           not null, indexed
#
# Indexes
#
#  index_communication_logs_on_context_type_and_context_id  (context_type,context_id)
#  index_communication_logs_on_patient_id                   (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#
require "rails_helper"

RSpec.describe CommunicationLog, type: :model do
  let(:log) { create(:communication_log) }

  context "validate#event_trigger" do
    it "only allows specified events" do
      SmsTemplate::APPOINTMENT_TYPES.each do |event|
        log.event_trigger = event
        expect(log).to be_valid
      end
    end
  end

  context "validate#patient" do
    it "requires patient to save" do
      expect(log.patient).to be_valid
      expect(log).to be_valid
    end

    it "does not allow invalid patient" do
      log.patient = nil
      expect(log).to_not be_valid
    end
  end
end
