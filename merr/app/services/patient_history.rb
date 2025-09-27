# typed: true
# frozen_string_literal: true

# Generates a patient history based from papertrail and AdminNotes.

class PatientHistory
  def initialize(patient)
    @patient = patient
  end

  def execute
    format_admin_notes
  end

  private

  def admin_notes
    AdminNote.where(notable_type: "Patient", notable_id: @patient.id).includes(:creator)
  end

  def format_admin_notes
    admin_notes.map do |admin_note|
      {
        type: "note",
        item: {
          id:        admin_note.id,
          username:  admin_note.creator.email,
          event:     "added a note",
          message:   admin_note.content,
          timestamp: admin_note.created_at
        }
      }
    end
  end
end
