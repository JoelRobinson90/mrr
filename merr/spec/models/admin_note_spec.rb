# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: admin_notes
#
#  id           :bigint           not null, primary key
#  content      :string
#  notable_type :string           not null, indexed => [notable_id]
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :integer          indexed
#  ma_id        :string           indexed
#  notable_id   :bigint           not null, indexed => [notable_type]
#
# Indexes
#
#  index_admin_notes_on_creator_id                   (creator_id)
#  index_admin_notes_on_ma_id                        (ma_id)
#  index_admin_notes_on_notable_type_and_notable_id  (notable_type,notable_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
require "rails_helper"

RSpec.describe AdminNote, type: :model do
  let(:creator) { FactoryBot.create(:user) }
  let(:noteable) { FactoryBot.create(:appointment) }

  before do
    allow(Alayacare::PushVisitNote).to receive(:call) { OpenStruct.new(success?: true) }
  end

  describe "does not require a creator as papertrail will monitor creator" do
    it "allows save without creator" do
      note = AdminNote.new(content: "Testing Content")
      noteable.admin_notes << note
      expect(noteable.valid?).to be_truthy
    end

    it "allows save with a creator" do
      note = AdminNote.new(content: "Testing Content", creator: creator)
      noteable.admin_notes << note
      expect(noteable.valid?).to be_truthy
      expect(note.valid?).to be_truthy
    end
  end

  describe "V2 flag" do
    let!(:field_provider) { create(:field_provider, external_id: "S132") }
    let!(:patient) do
      create(:patient, medical_record_number: "43klk3sdf0980", demand_partner: build(:demand_partner, name: "Molina"))
    end
    let!(:v2_program) { create(:program, v2: true) }
    let!(:program) { create(:program) }
    let!(:visit_type) { create(:visit_type, programs: [program], alayacare_id: "6") }
    let!(:visit) do
      create(:visit, program: v2_program, visit_type: visit_type, field_provider: field_provider, patient: patient,
      start_time: Time.zone.now + 24.hours, end_time: Time.zone.now + 25.hours)
    end
    let!(:user) { create(:medarrive_admin_user) }

    before do
      allow(Alayacare::PushVisitNote).to receive(:call).and_return(OpenStruct.new(success?: true))
    end

    it "should NOT sync to AC if visit.program.v2 flag is enabled" do
      note = AdminNote.new(notable_type: "Visit", notable_id: visit&.id,
                           content: "Note", creator_id: user.id)
      note.save
      expect(Alayacare::PushVisitNote).to_not have_received(:call)
    end

    it "should sync to AC if visit.program.v2 flag is NOT enabled" do
      visit.update_column(:program_id, program.id)
      note = AdminNote.new(notable_type: "Visit", notable_id: visit&.id,
                           content: "Note", creator_id: user.id)
      note.save
      expect(Alayacare::PushVisitNote).to have_received(:call) #  .with(patient, ["all"])
    end
  end

  describe "should_push_to_salesforce?" do
    it "returns false if notable is not a visit" do
      patient = create(:patient)
      allow(patient).to receive(:should_push_to_salesforce?) { true }
      note = build(:admin_note, notable: patient)

      expect(note.should_push_to_salesforce?).to be false
    end

    it "returns true if its visit should be synced" do
      visit = create(:visit)
      allow(visit).to receive(:should_push_to_salesforce?) { true }
      note = build(:admin_note, notable: visit)

      expect(note.should_push_to_salesforce?).to be true
    end

    it "returns false if its visit should not be synced" do
      visit = create(:visit)
      allow(visit).to receive(:should_push_to_salesforce?) { false }
      note = build(:admin_note, notable: visit)

      expect(note.should_push_to_salesforce?).to be false
    end
  end

  describe "ma_id" do
    context "on patient" do
      let(:admin_note) { create :admin_note, :on_patient }

      it "is prefixed with Patient" do
        expect(admin_note.ma_id).to match(/^spec_PatientAdminNote_\d+$/)
      end
    end

    context "on visit" do
      let(:admin_note) { create :admin_note, :on_visit }

      it "is prefixed with Visit" do
        expect(admin_note.ma_id).to match(/^spec_VisitAdminNote_\d+$/)
      end
    end
  end

  describe "to_ma_object" do
    let(:user) { create :medarrive_admin_user }
    let(:admin_note) { create :admin_note, :on_visit, creator: user }

    it "includes note content, notable association, and creator info" do
      expect(admin_note.to_ma_object).to match hash_including(
        content:         admin_note.content,
        notable_ma_type: "Visit",
        notable_ma_id:   admin_note.notable.ma_id,
        creator_email:   user.email,
        creator_name:    user.account.display_name,
        created_at:      admin_note.created_at.to_time
      )
    end
  end
end
