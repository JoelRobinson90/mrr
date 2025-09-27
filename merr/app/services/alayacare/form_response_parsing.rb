# typed: true
# frozen_string_literal: true

module Alayacare
  # Assumptions:
  # file is a open stream file
  # this file contains the most recent order's results for the patients listed
  # the client_id maps to our Patient ID
  # Question Tags <form_tag> are known and fixed so they can be mapped to display fields
  class FormResponseParsing

    def initialize(file, answer_parser)
      @csv = CSV.parse(file.read, headers: true)
      @answer_parser = answer_parser.constantize
      @questions_by_field_tag = {}
      @result = {}
    end

    def rows_parsed
      @csv.count
    end

    def form_responses
      # for each patient
      # create form response with the patient and appointment id
      # add the answers to this object
      # return the Response

      answers_by_patient.collect do |alayacare_clientid, answers|
        service_id = answers.first[:service_id]

        form_response = AlayacareForm::Response.create(
          alayacare_service_id: service_id,
          alayacare_patient_id: alayacare_clientid
        )

        # Check if alayacare has sent a patient with a known MRN
        patient = ::Patient.where(medical_record_number: alayacare_clientid).first
        form_response.patient = patient if patient

        # TODO: Add alayacare service mapping to appointment when updated in csv export

        form_response.answers = answers_from_responses(answers, form_response)
        form_response
      end
    end

    def answers_from_responses(responses, form_response)
      responses.collect do |answer|
        AlayacareForm::Answer.new(
          alayacare_answer_id: answer[:alayacare_answer_id],
          approved_date:       answer[:approved_date],
          field_tag:           answer[:field_tag],
          processor:           answer[:processor],
          question:            answer[:question],
          raw:                 answer[:raw],
          reply:               answer[:reply],
          response:            form_response
        )
      end
    end

    def answers_by_patient
      return @answers_by_patient if @answers_by_patient.present?

      @csv.each do |row|
        response = process_response(row)

        client_id =  row["client_id"].to_s
        service_id = row["service_id"]
        parsed_row = {
          alayacare_answer_id: response[:alayacare_answer_id],
          approved_date:       response[:approved_date],
          client_id:           client_id,
          processor:           response[:processor],
          question:            response[:question],
          raw:                 response[:raw],
          reply:               response[:reply],
          service_id:          service_id,
          field_tag:           response[:field_tag]
        }

        @result[client_id] ||= []
        @result[client_id].push(parsed_row)
      end

      @result
    end

    def questions_by_field_tag_and_client(field_tag, client_id)
      process_response[client_id].select do |response|
        response[:field_tag] == field_tag
      end
    end

    def question_answer_block_from_ids(field_tags)
      field_tags.collect do |id|
        result = questions_by_field_tag_and_client(id, client_id)
        {reply: result[:reply], question: result[:question]}
      end
    end

    def run_or_rescue(processor, body)
      send(processor, body)
    rescue StandardError => e
      Sentry.capture_exception(e)
      "Processor for #{body} using #{processor} errored with #{e}"
    end

    def process_response(answer_row)
      # from csv row
      # get question id, look up the question id in our processor set
      # parse the question's answer and return a structured result

      field_tag = answer_row.fetch("field_tag", "Unknown field tag")

      processor = if questions_by_field_tag.key?(field_tag)
                    questions_by_field_tag[field_tag][:processor]
                  else
                    smart_parser_chooser(answer_row)
                  end

      {
        approved_date:       answer_row["approved_date"],
        alayacare_answer_id: answer_row["answer_id"],
        field_tag:           answer_row["field_tag"],
        question:            answer_row["question_name"],
        reply:               run_or_rescue(processor, answer_row["answer"]),
        raw:                 answer_row.fetch("answer", "No response found on form"),
        processor:           processor
      }
    end

    def smart_parser_chooser(answer_row)
      warning = "Missing processor for question field_tag:#{answer_row['field_tag']} " \
                "answer:#{answer_row['question_name']}"
      Rails.logger.warn(warning)
      answer = answer_row["answer"]

      known_parsers = {
        # Assuming that this is a medication block
        medications:                "medication_name",

        # Vaccinations are slightly different but this works
        immunizations_administered: "booster_date",

        # Check respiratory rate first
        respiratory_rate:           "respiratory_rate",

        # Pulse
        pulse:                      "BPM",

        # Check for tempature
        temperature_and_unit:       "temperature",

        # Check for height
        height:                     "height",

        # Check for Weight
        weight_with_unit:           "weight",

        # Allergies. This is a questionable call as is not amazing
        allergies:                  "severity",

        #  BMI
        bmi:                        "body_mass",

        # past medical diagnosis
        past_medical_diagnoses:     "diagnosis",

        # Blood pressure
        blood_pressure:             "mmHg"
      }

      # this is a keyword to search for and a processor symbol to return
      known_parsers.each do |processor, keyword|
        return processor if answer.include?(keyword)
      end

      # at this point, we have done the easy ones.

      # multi select parser

      answer_parsed = body_parse(answer)

      # Hashed answers
      if answer_parsed.is_a?(Hash)
        # single response with other nested
        return :single_response_with_other if answer_parsed.dig("option", "value")

        # Single response with other option
        return :single_response_with_other if answer_parsed["other"]

        # any of the following horrible
        if answer_parsed.key?("options") && (answer_parsed["options"].is_a?(Array) && answer_parsed["options"][0].key?("name"))
          return :any_of_the_following
        end
      end

      :text
    end

    def questions_by_field_tag
      return @questions_by_field_tag unless @questions_by_field_tag.empty?

      @answer_parser.questions.each do |question|
        @questions_by_field_tag[question[:field_tag]] = question
      end

      @questions_by_field_tag
    end

    def attachment(body)
      # raise StandardError, "Attachments are not functional."
      "Attachments are not functional for #{body}"
    end

    def text(body)
      if body[0..1] == "b'"
        # Alayacare is sending byte string wrapped JSON bodies as results
        body[2..-2].strip
      else
        body.strip
      end
    end

    def body_parse(body)
      # Alayacare is sending byte string wrapped JSON bodies as results
      body = body[2..-2] if body[0..1] == "b'"

      # # Alayacare sends hashes wrapped in arrays breaking json
      # body = body[1..-1] if body[0] == "["

      JSON.parse(body)
    rescue StandardError => e
      Rails.logger.error("Failed to parse body #{e} #{body}")
      body
    end

    def medications(body)
      # [
      # values: [
      #   {field_key: "medication_name", field_value: "Protonix"},
      #   {field_key:   "medication_type",
      #    field_value: {option: {name: "prescriptions", value: "prescriptions"}}},
      #   {field_key: "status", field_value: {option: {name: "active", value: "active"}}},
      #   {field_key:   "information_source",
      #    field_value: {option: {name: "physician_rx", value: "physician_rx"}}},
      #   {field_key: "ordering_physician", field_value: null},
      #   {field_key: "high_alert", field_value: null},
      #   {field_key: "comments", field_value: null},
      #   {field_key: "discrepancy", field_value: null},
      #   {field_key: "discrepancy_status", field_value: null},
      #   {field_key: "discrepancy_note", field_value: null},
      #   {field_key: "healthcare_professional_notified", field_value: null},
      #   {field_key: "dose", field_value: "20"},
      #   {field_key: "dose_type", field_value: {option: {name: "mg", value: "mg"}}},
      #   {field_key: "route", field_value: {option: {name: "po_oral", value: "po_oral"}}},
      #   {field_key:   "administered_by",
      #    field_value: {option: {name: "not_assisted", value: "not_assisted"}}},
      #   {field_key: "delivery_mode", field_value: null},
      #   {field_key: "timing_unknown_start_date", field_value: true},
      #   {field_key: "timing_unknown_end_date", field_value: true},
      #   {field_key: "timing_start_date", field_value: null},
      #   {field_key: "timing_end_date", field_value: null},
      #   {field_key:   "time_instruction",
      #    field_value: {options: [{name: "qam_once_a_day_am", value: "qam_once_a_day_am"}]}},
      #   field_key:   "administration_times",
      #   field_value: null
      # ]
      # ]

      all_meds = body_parse(body)

      all_meds.collect do |row|
        values = row["values"]
        {
          name:             values.select {|k| k["field_key"] == "medication_name" }.first["field_value"],
          type:             values.select do |k|
                              k["field_key"] == "medication_type"
                            end.first.dig("field_value", "option", "name"),
          start_date:       values.select {|k| k["field_key"] == "timing_start_date" }.first["field_value"],
          dose:             values.select {|k| k["field_key"] == "dose" }.first["field_value"],
          dose_type:        values.select do |k|
            k["field_key"] == "dose_type"
          end.first.dig("field_value", "option", "name"),

          time_instruction: values.select do |k|
                              k["field_key"] == "time_instruction"
                            end.first.dig("field_value", "options").first["name"]
        }
      end
    end

    def allergies(body)
      # [
      #   values: [
      #     {field_key: "name", field_value: "Risperidone"},
      #     {field_key: "treatment", field_value: "Felt strange "},
      #     {field_key: "type", field_value: {option: {name: "Medication", value: "Medication"}}},
      #     {field_key: "severity", field_value: {option: {name: "Mild", value: "Mild"}}},
      #     field_key:   "date",
      #     field_value: null
      #   ]
      # ]

      all_allergies = body_parse(body)

      all_allergies.collect do |row|
        values = row["values"]
        {
          name:      values.select {|k| k["field_key"] == "name" }.first["field_value"],
          treatment: values.select {|k| k["field_key"] == "treatment" }.first["field_value"],
          type:      values.select do |k|
            k["field_key"] == "type"
          end.first.dig("field_value", "option", "name"),
          severity:  values.select {|k| k["field_key"] == "severity" }.first.dig("field_value", "option", "name"),
          date:      values.select {|k| k["field_key"] == "date" }.first["field_value"]
        }
      end
    end

    def pulse_ox(body)
      # [
      #   "values": [
      #     {"field_key": "unit", "field_value": {"option": {"name": "BPM", "value": "BPM"}}},
      #     {"field_key": "position", "field_value": {"option": {"name": "sitting", "value": "sitting"}}},
      #     "field_key": "pulse",
      #     "field_value": "98"
      #   ]
      # ]

      values = body_parse(body).first["values"]
      [
        values.select {|k| k["field_key"] == "unit" }.first["field_value"],
        values.select {|k| k["field_key"] == "position" }.first.dig("field_value", "option", "name"),
        values.select {|k| k["field_key"] == "pulse" }.first["field_value"]
      ].join(" ")
    end

    def blood_pressure(body)
      # [
      #   "values": [
      #     {"field_key": "systolic_pressure_unit", "field_value": {"option": {"name": "mmHg", "value": "mmHg"}}},
      #     {"field_key": "diastolic_pressure_unit", "field_value": {"option": {"name": "mmHg", "value": "mmHg"}}},
      #     {"field_key": "pressure_max", "field_value": "110"},
      #     {"field_key": "pressure_min", "field_value": "60"},
      #     "field_key": "position",
      #     "field_value": {"option": {"name": "sitting", "value": "sitting"}}
      #   ]
      # ]

      values = body_parse(body).first["values"]

      pressure_max = values.select {|k| k["field_key"] == "pressure_max" }.first["field_value"]
      pressure_min = values.select {|k| k["field_key"] == "pressure_min" }.first["field_value"]
      position = values.select {|k| k["field_key"] == "position" }.first.dig("field_value", "option", "name")

      units = values.select do |k|
        k["field_key"] == "systolic_pressure_unit"
      end.first["field_value"]

      [
        pressure_max,
        pressure_min,
        units,
        position
      ].join(" ")
    end

    def pulse(body)
      # [
      #   "values": [
      #     {"field_key": "unit", "field_value": {"option": {"name": "BPM", "value": "BPM"}}},
      #     {"field_key": "position", "field_value": {"option": {"name": "sitting", "value": "sitting"}}},
      #     "field_key": "pulse",
      #     "field_value": "98"
      #   ]
      # ]

      values = body_parse(body).first["values"]
      [
        values.select {|k| k["field_key"] == "unit" }.first["field_value"],
        values.select {|k| k["field_key"] == "position" }.first.dig("field_value", "option", "name"),
        values.select {|k| k["field_key"] == "pulse" }.first["field_value"]
      ].join(" ")
    end

    def respiratory_rate(body)
      # [
      #   values: [
      #     {field_key: "unit", field_value: {option: {name: "BPM", value: "BPM"}}},
      #     field_key:   "respiratory_rate",
      #     field_value: "18"
      #   ]
      # ]

      values = body_parse(body).first["values"]
      [
        values.select {|k| k["field_key"] == "respiratory_rate" }.first["field_value"],
        values.select {|k| k["field_key"] == "unit" }.first["field_value"]
      ].join(" ")
    end

    def temperature_and_unit(body)
      # [
      #   "values": [
      #     {"field_key": "route", "field_value": {"option": {"name": "temporal", "value": "temporal"}}},
      #     {"field_key": "temperature", "field_value": 97.8},
      #     "field_key": "unit",
      #     "field_value": {"option": {"name": "f", "value": "f"}}
      #   ]
      # ]
      values = body_parse(body).first["values"]
      [
        values.select {|k| k["field_key"] == "temperature" }.first["field_value"],
        values.select {|k| k["field_key"] == "unit" }.first.dig("field_value", "option", "name"),
        values.select {|k| k["field_key"] == "route" }.first.dig("field_value", "option", "name")
      ].join(" ")
    end

    def height(body)
      # [
      #   "values": [
      #     {"field_key": "height", "field_value": "167"},
      #     "field_key": "unit",
      #     "field_value": {"option": {"name": "cm", "value": "cm"}}
      #   ]
      # ]
      #
      values = body_parse(body).first["values"]
      [
        values.select {|k| k["field_key"] == "height" }.first["field_value"],
        values.select {|k| k["field_key"] == "unit" }.first.dig("field_value", "option", "name")
      ].join(" ")
    end

    def weight_with_unit(body)
      # [
      # "values": [
      #   {"field_key": "unit", "field_value": {"option": {"name": "lb", "value": "lb"}}},
      #   "field_key": "weight",
      #   "field_value": "144"
      # ]
      # ]

      values = body_parse(body).first["values"]
      [
        values.select {|k| k["field_key"] == "weight" }.first["field_value"],
        values.select {|k| k["field_key"] == "unit" }.first.dig("field_value", "option", "name")
      ].join(" ")
    end

    def bmi(body)
      # [
      #   "values": [
      #     {"field_key": "body_mass", "field_value": 23.2},
      #     {"field_key": "unit", "field_value": {"option": {"name": "kg/m2", "value": "kg/m2"}}},
      #     "field_key": "comments",
      #     "field_value": "FSBG 131"
      #   ]
      # ]
      values = body_parse(body).first["values"]

      [
        values.select {|k| k["field_key"] == "body_mass" }.first["field_value"],
        values.select {|k| k["field_key"] == "unit" }.first["field_value"]
      ].join(" ")
    end

    def past_medical_diagnoses(body)
      # [
      #   values: [
      #     {field_key:   "diagnosis",
      #      field_value: "J440=Chronic obstructive pulmonary disease with (acute) lower respiratory infection"},
      #     {field_key: "treatment", field_value: null},
      #     {field_key: "start_date", field_value: "2020-08-04"},
      #     {field_key: "end_date", field_value: null},
      #     field_key:   "notes",
      #     field_value: null
      #   ]
      # ]

      past_diag = body_parse(body)

      past_diag.collect do |row|
        values = row["values"]
        {
          diagnosis: values.select {|k| k["field_key"] == "diagnosis" }.first["field_value"]
        }
      end
    end

    def patient_self_reported_vaccinations(body)
      # [
      #   "values": [
      #     {"field_key": "type", "field_value": {"option": {"name": "Tuberculosis (BCG)", "value": "Tuberculosis (BCG)"}}},
      #     {"field_key": "date", "field_value": "1961-01-01"},
      #     "field_key": "booster_date",
      #     "field_value": null
      #   ]
      # ]

      past_diag = body_parse(body)

      past_diag.collect do |row|
        values = row["values"]
        name = values.select {|k| k["field_key"] == "type" }.first.dig("field_value", "option", "name")
        date = values.select {|k| k["field_key"] == "date" }.first["field_value"]

        "#{name} on #{date}"
      end.join('\n')
    end

    def immunizations_administered(body)
      # [
      #   values: [
      #     {field_key: "type", field_value: {other: "COVID-19"}},
      #     {field_key: "date", field_value: "2021-08-16"},
      #     field_key:   "booster_date",
      #     field_value: null
      #   ]
      # ]

      past_diag = body_parse(body)

      past_diag.collect do |row|
        values = row["values"]
        {
          type: values.select {|k| k["field_key"] == "type" }.first.dig("field_value", "other"),
          date: values.select {|k| k["field_key"] == "date" }.first["field_value"]
        }
      end
    end

    def any_of_the_following(body)
      # {options: [{name: "Nausea", value: "Nausea"}, {name: "Headache", value: "Headache"},
      #            {name: "Difficulty thinking clearly,", value: "Difficulty thinking clearly,"}]}

      following = body_parse(body)["options"]

      following.collect do |row|
        row["name"]
      end.join(", ")
    end

    def single_response_with_other(body)
      # {"option": {"name": "Yes", "value": "Yes"}}

      result = body_parse(body).dig("option", "value")

      # For results with "other option"
      result || body_parse(body)["other"]
    rescue JSON::ParserError, TypeError, NoMethodError => e
      Rails.logger.debug { "Json parse fail for string with options. #{body}, #{e}" }
      body
    end
  end
end
