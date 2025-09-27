# frozen_string_literal: true

# typed: true
class VisitSummaryPdfExport < BasePdfLayout
  GRAY_COLOR = "929292"
  def initialize(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @form = ::Alayacare::VisitSummaryForm.new(@appointment)
    @formatter = BaseFormatter.new
    super()
  end

  def body_section
    footer_section

    y_position = cursor
    med_section_header("Patient Information")

    patient_metadata

    summary_of_visits
    history_present_illness
    medications
    allergies
    patient_exam
    past_medical_history
    social_history
    review_plan

    string = "<page>/<total>"

    options = {
      at:             [bounds.right - 150, -10],
      width:          150,
      align:          :right,
      start_count_at: 1,
      color:          GRAY_COLOR,
      font_size:      8
    }
    number_pages string, options
  end

  def patient_metadata
    y_position = cursor
    table([
            ["Patient Name", @patient.full_name],
            ["Phone Number", @patient.phone_number],
            ["MRN", @patient&.medical_record_number],
            ["Appointment Date", @appointment.start_time.strftime("%m/%d/%Y")]
          ])
    move_down 40
  end

  def summary_of_visits
    summary_section(title: "Summary of Visits") do
      @formatter.render(@form.summary_of_visits)
    end
  end

  def history_present_illness
    move_down 20

    summary_section(title: "History of Present Illness") do
      @formatter.render(@form.history_of_present_illness)
    end
  end

  def past_medical_history
    move_down 20

    summary_section(title: "Past Medical History") do
      @formatter.render(@form.past_medical_history)
    end
  end

  def medications
    move_down 20

    summary_section(title: "Medications") do
      @formatter.render(@form.medications)
    end

    table(@formatter.render(@form.medications_table), default_table_options)

    summary_section(title: nil) do
      @formatter.render(@form.medications_footer)
    end
  end

  def allergies
    move_down 20

    summary_section(title: "Ask patient if he/she has any allergies and list in the table below:") do
      [["<b>Allergies</b>"]]
    end

    table(@formatter.render(@form.allergies_table), default_table_options)
  end

  def immunizations_reported
    # @TODO: don't see it on the CSV yet
  end

  def patient_exam
    move_down 20

    summary_section(title: nil) do
      [["<b>Patient Exam</b>"]]
    end
    summary_section(title: nil) do
      @formatter.render(@form.patient_exam_table)
    end

    summary_section(title: nil) do
      @formatter.render(@form.patient_exam_footer)
    end
  end

  def social_history
    move_down 20
    diet_block                            = @formatter.render(@form.diet_block)
    ability_to_purchase_medications_block = @formatter.render(@form.ability_to_purchase_medications_block)
    allergens_block                       = @formatter.render(@form.allergens_block)
    tobbaco_block                         = @formatter.render(@form.tobbaco_block)
    ability_to_get_appointments_block     = @formatter.render(@form.ability_to_get_appointments_block)
    outside_of_house_block                = @formatter.render(@form.outside_of_house_block)
    living_room_block                     = @formatter.render(@form.living_room_block)
    kitchen_block                         = @formatter.render(@form.kitchen_block)
    stairs_block                          = @formatter.render(@form.stairs_block)
    stairs_block                          = @formatter.render(@form.stairs_block)
    bathroom_block                        = @formatter.render(@form.bathroom_block)

    summary_section(title: "Social History") do
      @formatter.render(@form.diet_block)
    end

    summary_section(title: nil) do
      @formatter.render(@form.ability_to_purchase_medications_block)
    end

    summary_section(title: nil) do
      @formatter.render(@form.allergens_block)
    end

    summary_section(title: nil) do
      @formatter.render(@form.tobbaco_block)
    end
  end

  def review_plan
    move_down 20

    summary_section(title: "Past Medical History") do
      @formatter.render(@form.review_plan)
    end
  end

  private

  def summary_section(title:)
    rows = yield

    rows.unshift([title]) if title.present?
    table(rows, header: true, cell_style: {inline_format: true}, width: 540) do
      cells.padding = 7
      cells.border_width = 1
      row(0).font_style = :bold if title.present?
      row(1..(rows.count - 1)).borders = %i[left right]
    end
    stroke do
      horizontal_rule
    end
  end

  def default_table_options
    {cell_style: {inline_format: true}, width: 540}
  end

  def footer_section
    repeat(:all, dynamic: true) do
      font_size(8) do
        footer_text(text: "Patient: #{@patient.full_name} (MRN: #{@patient&.medical_record_number})", x: 0, y: -10)
      end
    end
  end

  def footer_text(text:, x:, y:)
    formatted_text_box(
      [
        {
          text: text,
          color: GRAY_COLOR, styles: [:italic]
        }
      ],
      at: [x, y], width: 200, height: 100
    )
  end
end
