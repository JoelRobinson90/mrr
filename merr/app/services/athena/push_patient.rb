# typed: true
# frozen_string_literal: true

module Athena
  class PushPatient < ApiClient
    def initialize(patient, program, department_id: nil)
      super()

      @patient = patient
      @address = @patient.address

      @program = program

      @department_id = department_id || patient.demand_partner.get_athena_department(patient)&.athena_id

      @custom_fields = {
        "MedArrive Patient ID" => @patient.ma_id
      }

      # Default insurance package is "0" for SELF PAY.
      @insurance_package_id = 0
    end

    def call
      existing_id = @patient.athena_id || find_existing_athena_id

      result = if existing_id.present?
                 @api.put("patients/#{existing_id}", body)
               else
                 @api.post("patients", body)
               end

      return result unless result.success?

      result_id = JSON.parse(result.body).dig(0, "patientid")
      @patient.paper_trail.update_columns("athena_id" => result_id)

      PushCustomFields.call(@patient, @custom_fields, @department_id)

      # Add insurance info (will not override existing)
      if @program && @insurance_package_id.present?
        @api.post("patients/#{result_id}/insurances", insurance_body)
      end

      OpenStruct.new(success?: true, payload: @patient)
    end

    def find_existing_athena_id
      existing_result = @api.get("patients/enhancedbestmatch",
                                 duplicate_check_body)

      return nil unless existing_result.success?

      existing_body = JSON.parse(existing_result.body)
      return nil if existing_body.blank?

      # a sufficiently high match will return a single element,
      # but usually body is an array.  We only care about the best option.
      existing = existing_body[0] if existing_body.is_a? Array

      return existing["patientid"] if (existing["score"] || 0).to_i > 23

      nil
    end

    def body
      preferred_language_code = Patient::LANGUAGES[@patient.preferred_language]

      {
        departmentid:                   @department_id,
        firstname:                      @patient.first_name,
        lastname:                       @patient.last_name,
        dob:                            @patient.date_of_birth.strftime("%m/%d/%Y"),
        homephone:                      @patient.phone_number.gsub("+1", ""),
        email:                          @patient.contact_email,
        sex:                            athena_format_sex(@patient.sex),
        consenttocall:                  false,
        guarantorrelationshiptopatient: 1,
        language6392code: preferred_language_code
      }.merge(address_block).compact_blank
    end

    def duplicate_check_body
      body.slice(:firstname, :lastname, :dob, :homephone,
                 :sex, :address1, :address2, :city, :state, :zip)
    end

    def address_block
      if @address
        {
          address1: @address.address_line_one,
          address2: @address.address_line_two,
          city:     @address.city,
          state:    @address.state,
          zip:      @address.zipcode
        }
      else
        {}
      end
    end

    def insurance_body
      insurance = InsurancePolicy.where(patient: @patient, program: @program).last

      defaults = {
        insurancepackageid:             @insurance_package_id || insurance&.insurance_package_id,
        insurancepolicyholderfirstname: @patient.first_name,
        insurancepolicyholderlastname:  @patient.last_name,
        insurancepolicyholdersex:       athena_format_sex(@patient.sex),
        relationshiptoinsuredid:        1, # self
        insuranceidnumber:              @patient.medical_record_number,
        sequencenumber:                 1, # primary
        insuredentitytypeid:            1 # person
      }
      return defaults if insurance.blank?

      insurance_hash = {
        insurancepackageid:             insurance.insurance_package_id,
        insurancepolicyholderfirstname: insurance.policy_holder_first_name,
        insurancepolicyholderlastname:  insurance.policy_holder_last_name,
        insurancepolicyholdersex:       athena_format_sex(insurance.policy_holder_sex),
        relationshiptoinsuredid:        insurance.relationship_to_insured_id,
        insuranceidnumber:              insurance.insurance_id_number,
        sequencenumber:                 insurance.insurance_sequence_number
      }.select {|_, value| value.present? }

      defaults.merge(insurance_hash)
    end

    def athena_format_sex(sex)
      return "F" if %w[F Female].include? sex
      return "M" if %w[M Male].include? sex

      nil
    end
  end
end
