# frozen_string_literal: true

# typed: true
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
require "rails_helper"

RSpec.describe Tag, type: :model do
  context "Required fields for tags" do
    let(:tag) { build(:tag, group: "Appointment") }

    context "name" do
      it "validates name" do
        tag.name = nil
        expect(tag).to_not be_valid
      end

      it "validates name unique in group" do
        tag.save!
        dup_tag = build(:tag, name: tag.name, group: tag.group)
        expect(dup_tag).to_not be_valid

        dup_tag.group = "Patient"
        expect(dup_tag).to be_valid
      end
    end

    it "validates color" do
      tag.color = "Suncrusher"
      expect(tag).to_not be_valid
    end

    it "has functional factory" do
      tag = build(:tag)

      expect(tag).to be_valid
    end
  end

  context "appointment tags" do
    let(:tag_diabetic) { create(:tag, group: "Appointment", name: 'Diabetic') }
    let(:tag_hypertensive) { create(:tag, group: "Appointment", name: 'Hypertensive') }
    let(:appointment) { create(:appointment, patient: create(:patient, needs_hra_survey: false), tag_list: [tag_diabetic.name, tag_hypertensive.name]) }

    it "should remove tag from appointments after archiving it" do
      expect(appointment.tag_list).to match_array [tag_diabetic.name, tag_hypertensive.name]
      tag_diabetic.destroy
      appointment.reload
      expect(appointment.tag_list).to match_array [tag_hypertensive.name]
    end
  end

  context "patient tags" do
    let(:tag_diabetic) { create(:tag, group: "Patient", name: 'Diabetic') }
    let(:tag_hypertensive) { create(:tag, group: "Patient", name: 'Hypertensive') }
    let(:patient) { create(:patient, tag_list: [tag_diabetic.name, tag_hypertensive.name]) }

    it "should remove tag from patients after archiving it" do
      expect(patient.tag_list).to match_array [tag_diabetic.name, tag_hypertensive.name]
      tag_diabetic.destroy
      patient.reload
      expect(patient.tag_list).to match_array [tag_hypertensive.name]
    end
  end
end
