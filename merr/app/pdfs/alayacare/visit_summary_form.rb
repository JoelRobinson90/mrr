# frozen_string_literal: true

# typed: true
module Alayacare
  class VisitSummaryForm

    def initialize(appointment)
      @appointment = appointment
      @order = @appointment.order

      # TODO: REMOVE THE FILE PATH AFTER WE FIGURE OUT HOW TO SPLIT THIS UP
      @file_path = "./form_data/cf.csv"
      @data_processor = Alayacare::FormResponseParsing.new(@file_path)
      @csv_data = @data_processor.process_csv
      @template = Alayacare::FormTemplate::Form100a
    end

    def summary_of_visits
      question_ids = @template.collect_question_ids(@template.summary_of_visits)
      {
        type:  "list",
        items: question_ids.collect {|id| @csv_data[id] }
      }
    end

    def history_of_present_illness
      question_ids = @template.collect_question_ids(@template.history_of_present_illness)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:  "questions",
        items: item_block
      }
    end

    def past_medical_history
      question_ids = @template.collect_question_ids(@template.past_medical_history)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:  "questions",
        items: item_block
      }
    end

    def medications
      question_ids = @template.collect_question_ids(@template.medications)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:  "questions",
        items: item_block
      }
    end

    def medications_table
      # Only a single question right now
      question_ids = @template.collect_question_ids(@template.medications_table).first

      meds = @csv_data[question_ids].collect do |r|
        [
          r[:name], r[:start_date], r[:dosage], r[:time_instructions]
        ]
      end

      {
        type:    "table",
        columns: ["Medication Name", "Start Date", "Dosage", "Time Instruction"],
        rows:    meds
      }
    end

    def medications_footer
      question_ids = @template.collect_question_ids(@template.medications_footer)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:  "questions",
        items: item_block
      }
    end

    def allergies_table
      question_id = @template.collect_question_ids(@template.allergies_table).first

      allergies = @csv_data[question_id].collect do |r|
        [
          r[:name], r[:treatment], r[:type], r[:severity], ""
        ]
      end

      {
        type:    "table",
        columns: ["Allergy Name", "Treatment", "Type", "Severity", "Date"],
        rows:    allergies
      }
    end

    def patient_exam_table
      {
        type:    "table",
        columns: nil,
        rows:    [
          ["Temperature", "97.8 f, temporal"],
          ["Blood Pressure", "110.0/60.0 mmHg, sitting"],
          ["Respiratory Rate", "18.0 BPM"],
          ["Pulse Ox", "98.0 BPM, sitting"],
          ["Pulse", "66.0 BPM, sitting"],
          ["Height", "65.75 in"],
          ["Weight", "144.0 lb"],
          ["BMI", "23.2kg/m2 "],
          ["Finger Stick Blood Glucose (FSBG)", "131"]
        ]
      }
    end

    def patient_exam_footer
      question_ids = @template.collect_question_ids(@template.patient_exam_footer)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:  "questions",
        items: item_block
      }
    end

    def review_plan
      # TODO: Missing questions
      question_ids = @template.collect_question_ids(@template.review_plan)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:  "questions",
        items: item_block + [
          {
            question: "Inform patient their PCP will be giving him/her any results from specimen collected at visit, if applicable",
            answer:   "..."
          },
          {
            question: "Assure patient that all the information gathered today will be transmitted to his/her doctor",
            answer:   "..."
          },
          {
            question: "Summarize Reviewing Plan with patient (describe patient’s understanding of findings from the visit, instructions of discharge summary/use of meds, and understanding of PCP follow-up visit):",
            answer:   "..."
          }
        ]
      }
    end

    def diet_block
      question_ids = @template.collect_question_ids(@template.diet_block)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:    "questions",
        prepend: "Diet",
        items:   item_block
      }
    end

    def ability_to_purchase_medications_block
      question_ids = @template.collect_question_ids(@template.ability_to_purchase_medications_block)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:    "questions",
        prepend: "Ability to Purchase Medications",
        items:   item_block
      }
    end

    def allergens_block
      # TODO: Missing Question
      question_ids = @template.collect_question_ids(@template.allergens_block)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:    "questions",
        prepend: "Allergens",
        items:   item_block + [
          {
            question: "Pictures of the mold if present",
            answer:   "No"
          }
        ]
      }
    end

    def tobbaco_block
      question_ids = @template.collect_question_ids(@template.tobbaco_block)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:    "questions",
        prepend: "Tobacco HX",
        items:   item_block
      }
    end

    def ability_to_get_appointments_block
      question_ids = @template.collect_question_ids(@template.ability_to_get_appointments_block)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:    "questions",
        prepend: "Ability to get Appointments",
        items:   item_block
      }
    end

    def outside_of_house_block
      question_ids = @template.collect_question_ids(@template.outside_of_house_block)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:    "questions",
        prepend: "Outside of house",
        items:   item_block
      }
    end

    def living_room_block
      question_ids = @template.collect_question_ids(@template.living_room_block)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:    "questions",
        prepend: "Living room",
        items:   item_block
      }
    end

    def kitchen_block
      question_ids = @template.collect_question_ids(@template.kitchen_block)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:    "questions",
        prepend: "Kitchen",
        items:   item_block
      }
    end

    def stairs_block
      question_ids = @template.collect_question_ids(@template.stairs_block)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:    "questions",
        prepend: "Stairs",
        items:   item_block
      }
    end

    def bathroom_block
      question_ids = @template.collect_question_ids(@template.bathroom_block)
      item_block = @data_processor.question_answer_block_from_ids(question_ids)

      {
        type:    "questions",
        prepend: "Bathroom",
        items:   item_block
      }
    end
  end
end
