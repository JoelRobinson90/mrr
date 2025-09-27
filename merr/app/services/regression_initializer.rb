# frozen_string_literal: true

# typed: true
class RegressionInitializer < ApplicationService
  def initialize
    @id_keys = %i[external_id ma_id medical_record_number name code email]
    @non_persisted_keys = %i[skip_push_to_alayacare]

    @created = []
    @matched = []
    @updated = []
    @failed = []

    @something_failed = false
  end

  def call
    return payload_data(err: "Can not run on production server.") if EnvHelper.env_or_nil("ENV") == "prod"

    # Disable external updates
    salesforce_push_was_enabled = Flipper.enabled?(:push_to_salesforce)
    Flipper.disable(:push_to_salesforce)
    push_to_external_was_enabled = EnvHelper.env_or_nil("ENABLE_PUSH_TO_EXTERNAL")
    ENV["ENABLE_PUSH_TO_EXTERNAL"] = "false"

    begin
      #-----------------------------------------------------------
      #                      Demand Partners
      #-----------------------------------------------------------
      demand_partner = find_or_create(DemandPartner,
                                      {ma_id:      "reg_DemandPartner_1",
                                       name:       "Regression Demand Partner",
                                       short_name: "Regression Demand Partner"})

      field_org = find_or_create(FieldOrg, {name: "Regression Field Org"})

      return payload_data if @something_failed

      #-----------------------------------------------------------
      #                         Programs
      #-----------------------------------------------------------
      program = find_or_create(Program, {name:                      "Regression Program",
                                         ma_id:                     "reg_Program_1",
                                         alayacare_service_code_id: "",
                                         demand_partner_id:         demand_partner.id,
                                         v2:                        true})

      v1_program = find_or_create(Program, {name:                      "v1 Regression Program",
                                            ma_id:                     "reg_Program_2",
                                            alayacare_service_code_id: "",
                                            demand_partner_id:         demand_partner.id,
                                            v2:                        false})

      #-----------------------------------------------------------
      #                         Services
      #-----------------------------------------------------------
      service = find_or_create(Service, {name:         "Regression Service",
                                         alayacare_id: "341",
                                         duration:     30})

      optional_service = find_or_create(Service, {name:         "Optional Regression Service",
                                                  alayacare_id: "100",
                                                  duration:     30})

      #-----------------------------------------------------------
      #                         Cancel codes
      #-----------------------------------------------------------
      cancel_code = find_or_create(CancelCode, {code:         "Regression Cancel Code",
                                                ma_id:        "reg_CancelCode_1",
                                                alayacare_id: "13"})

      #-----------------------------------------------------------
      #                         Visit types
      #-----------------------------------------------------------
      visit_type = find_or_create(VisitType, {name:              "Regression Visit Type",
                                              ma_id:             "reg_VisitType_1",
                                              plus_ones_enabled: true,
                                              alayacare_id:      "102"})

      v1_visit_type = find_or_create(VisitType, {name:              "v1 Regression Visit Type",
                                                 ma_id:             "reg_VisitType_2",
                                                 plus_ones_enabled: true,
                                                 alayacare_id:      "19"})

      multi_resource_visit_type = find_or_create(VisitType, {name:              "Regression Multi-resource Type",
                                                             ma_id:             "reg_VisitType_3",
                                                             plus_ones_enabled: true,
                                                             alayacare_id:      "19"})

      virtual_only_visit_type = find_or_create(VisitType, {name:              "Regression Virtural-only Type",
                                                           ma_id:             "reg_VisitType_4",
                                                           plus_ones_enabled: true,
                                                           alayacare_id:      "19"})

      return payload_data if @something_failed

      #-----------------------------------------------------------
      #                        Patients
      #-----------------------------------------------------------

      patient = find_or_create(Patient, {first_name:             "Regression",
                                         last_name:              "Patient",
                                         ma_id:                  "reg_Patient_1",
                                         medical_record_number:  "Reg-patient-01",
                                         external_id:            "Reg-patient-external-01",
                                         date_of_birth:          Date.parse("1985-04-20"),
                                         phone_number:           "+17345467319",
                                         demand_partner_id:      demand_partner.id,
                                         skip_push_to_alayacare: true})

      v1_patient = find_or_create(Patient, {first_name:             "v1 Regression",
                                            last_name:              "Patient",
                                            ma_id:                  "reg_Patient_2",
                                            medical_record_number:  "Reg-patient-02",
                                            external_id:            "Reg-patient-external-02",
                                            date_of_birth:          Date.parse("1985-04-20"),
                                            phone_number:           "+17345467319",
                                            demand_partner_id:      demand_partner.id,
                                            skip_push_to_alayacare: true})

      #-----------------------------------------------------------
      #                        Providers
      #-----------------------------------------------------------

      fp = find_or_create(FieldProvider, {first_name:   "Regression",
                                          last_name:    "FP",
                                          ma_id:        "reg_FieldProvider_1",
                                          external_id:  "Reg-fp-01",
                                          field_org_id: field_org.id})

      fp2 = find_or_create(FieldProvider, {first_name:   "Second Regression",
                                           last_name:    "FP",
                                           ma_id:        "reg_FieldProvider_2",
                                           external_id:  "Reg-fp-02",
                                           field_org_id: field_org.id})

      sw = find_or_create(FieldProvider, {first_name:   "Regression",
                                          last_name:    "Social Worker",
                                          role:         "social_worker",
                                          ma_id:        "reg_FieldProvider_3",
                                          external_id:  "Reg-fp-03",
                                          field_org_id: field_org.id})

      np = find_or_create(FieldProvider, {first_name:   "Regression",
                                          last_name:    "Nurse Practitioner",
                                          role:         "nurse_practitioner",
                                          ma_id:        "reg_FieldProvider_4",
                                          external_id:  "Reg-fp-04",
                                          field_org_id: field_org.id})

      return payload_data if @something_failed

      #-----------------------------------------------------------
      #                Visit resource requirements
      #-----------------------------------------------------------
      fp_resource = {
        duration: 30,
        in_home: true,
        offset: 0,
        provider_role: "field_provider"
      }

      np_resource = {
        duration: 15,
        in_home: false,
        offset: 15,
        provider_role: "nurse_practitioner"
      }

      result = set_visit_resource_requirements(multi_resource_visit_type, [fp_resource, np_resource])
      return result unless result.success?

      sw_resource = {
        duration: 30,
        in_home: false,
        offset: 0,
        provider_role: "social_worker"
      }

      result = set_visit_resource_requirements(virtual_only_visit_type, [sw_resource])
      return result unless result.success?

      #-----------------------------------------------------------
      #                         Emails
      #-----------------------------------------------------------
      find_or_create_email(fp, "regression-fp@medarrive.com")
      find_or_create_email(fp2, "regression-fp-02@medarrive.com")
      find_or_create_email(np, "regression-np@medarrive.com")

      #-----------------------------------------------------------
      #                        Addresses
      #-----------------------------------------------------------
      default_address_hash = {address_line_one: "1330 Grand Ave",
                              city:             "Des Moines",
                              state:            "IA",
                              zipcode:          "50309"}

      find_or_create_address(patient, default_address_hash)
      find_or_create_address(v1_patient, default_address_hash)
      find_or_create_address(fp, default_address_hash)
      find_or_create_address(sw, default_address_hash)
      find_or_create_address(np, default_address_hash)
      find_or_create_address(fp2, {address_line_one: "2507 University Ave",
                                   city:             "Des Moines",
                                   state:            "IA",
                                   zipcode:          "50311"})

      return payload_data if @something_failed

      #-----------------------------------------------------------
      #                         Join tables
      #-----------------------------------------------------------
      # v1 join tables
      ProgramVisitType.find_or_create_by(program_id: v1_program.id, visit_type_id: v1_visit_type.id)
      ProgramService.find_or_create_by(program_id: v1_program.id, service_id: service.id)
      ProgramService.find_or_create_by(program_id: v1_program.id, service_id: optional_service.id)
      VisitTypeService.find_or_create_by(visit_type_id: v1_visit_type.id, service_id: service.id)
      PatientProgram.find_or_create_by(patient_id: v1_patient.id, program_id: v1_program.id)

      # v2 join tables
      ProgramVisitType.find_or_create_by(program_id: program.id, visit_type_id: visit_type.id)
      ProgramVisitType.find_or_create_by(program_id: program.id, visit_type_id: multi_resource_visit_type.id)
      ProgramService.find_or_create_by(program_id: program.id, service_id: service.id)
      ProgramService.find_or_create_by(program_id: program.id, service_id: optional_service.id)
      VisitTypeService.find_or_create_by(visit_type_id: visit_type.id, service_id: service.id)
      VisitTypeService.find_or_create_by(visit_type_id: multi_resource_visit_type.id, service_id: service.id)
      PatientProgram.find_or_create_by(patient_id: patient.id, program_id: program.id)

      #-----------------------------------------------------------
      #                         Athena sync
      #-----------------------------------------------------------
      sync_results = [
        Athena::PullExternalData.call(AthenaDepartment, "departments"),
        Athena::PullExternalData.call(CancelCode, "appointmentcancelreasons"),
        Athena::PullExternalData.call(VisitType, "appointmenttypes"),
        Athena::PullExternalData.call(Service, "configuration/encounterreasons"),
        Athena::PullExternalData.call(AthenaCustomField, "customfields"),
        Athena::PullExternalData.call(AthenaCustomField, "appointments/customfields",
                                      athena_wrapper_key: "appointmentcustomfields")
      ]

      unless sync_results.map(&:success?).all?
        return payload_data(err: "Athena sync failed. Try running each sync manually.")
      end
    ensure
      Flipper.enable(:push_to_salesforce) if salesforce_push_was_enabled
      ENV["ENABLE_PUSH_TO_EXTERNAL"] = "true" if push_to_external_was_enabled
    end

    payload_data
  end

  #-----------------------------------------------------------------
  #                         Helper methods
  #-----------------------------------------------------------------

  def payload_data(err: nil)
    payload = {created: @created, matched: @matched, updated: @updated, failed: @failed}
    if @something_failed || err
      OpenStruct.new(success?: false, payload: payload, error: err || "Something went wrong")
    else
      OpenStruct.new(success?: true, payload: payload)
    end
  end

  def find_or_create_email(parent_obj, email)
    user_hash = {
      email: email,
      account_type: parent_obj.class.name,
      account_id: parent_obj.id
    }

    find_or_create(User, user_hash)
  end

  def find_or_create_address(parent_obj, attributes)
    address = parent_obj.address

    if address.blank?
      address = parent_obj.create_address(attributes)
    elsif needs_update?(address, attributes)
      address.update(attributes)
    end

    @failed << error_message(address) unless address.errors.empty?
  end

  def find_or_create(klass, attributes, existing_obj: nil)
    obj = existing_obj || find_existing(klass, attributes)

    # create
    if obj.blank?
      obj = klass.create(attributes)
      if obj.persisted?
        @created << get_label(obj)
      else
        @failed << error_message(obj)
      end
    # update
    elsif needs_update?(obj, attributes)
      obj.update(attributes)
      if obj.errors.empty?
        @updated << get_label(obj)
      else
        @failed << error_message(obj)
      end
    # matched
    else
      @matched << get_label(obj)
    end

    obj
  end

  def needs_update?(obj, attributes)
    # don't compare any attr_accessors
    persisted_attributes = attributes.reject {|k, _v| @non_persisted_keys.include? k }

    # for all other keys, if it doesn't match then we need to update
    result = persisted_attributes.map {|k, v| obj[k].to_s != v.to_s }.any?

    result
  end

  def find_existing(klass, attributes)
    columns = klass.column_names.map(&:to_sym)

    @id_keys.each do |id_key|
      # p "LOOKING BY: #{id_key}"
      # p "IN CLASS: #{columns.include? id_key}"
      # p "IN ATTRIBUTES: #{attributes[id_key].present?}"
      next unless columns.include?(id_key) && attributes[id_key].present?

      obj = klass.find_by(id_key => attributes[id_key])
      return obj if obj.present?
    end
    nil
  end

  def set_visit_resource_requirements(visit_type, resources)
    # attempt to create
    find_or_create_visit_resource_requirements(visit_type, resources)

    # if there are too many, clear and try again
    if visit_type.visit_resource_requirements.count != resources.length
      visit_type.visit_resource_requirements.delete_all
      find_or_create_visit_resource_requirements(visit_type, resources)
    end

    # still not right? Throw an error
    if visit_type.visit_resource_requirements.count != resources.length
      err = "Clear #{visit_type.name} resource requirements and try again."
      return payload_data(err: err)
    end

    OpenStruct.new(success?: true)
  end

  def find_or_create_visit_resource_requirements(visit_type, resources)
    resources.each do |resource_hash|
      resource_hash[:visit_type_id] = visit_type.id
      VisitResourceRequirement.find_or_create_by(resource_hash)
    end
  end

  def error_message(obj)
    @something_failed = true
    action = obj.persisted? ? "update" : "create"
    "Failed to #{action} #{get_label(obj)}: #{obj.errors.full_messages.to_sentence}"
  end

  def get_label(obj)
    return "Address for #{get_label(obj.addressable)}" if obj.instance_of?(Address)

    label_keys = %i[name first_name code ma_id external_id email]
    label_value = obj.to_s

    label_keys.each do |label_key|
      next if obj[label_key].blank?

      label_value = obj[label_key]
      label_value += " #{obj[:last_name]}" if label_key == :first_name
      break
    end

    "[#{obj.class.name}] #{label_value}"
  end
end
