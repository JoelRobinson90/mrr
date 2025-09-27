# frozen_string_literal: true

namespace :db do
  desc "Add data fixtures to run automated regression tests."
  task seed_regression: :environment do
    @something_failed = false

    def check_progress(obj)
      if obj.persisted?
        p "Created or found #{obj.class.name}"
      else
        p "Failed to create #{obj.class.name}: #{obj.errors.full_messages.to_sentence}"
        @something_failed = true
      end
    end

    if Rails.env.production? || EnvHelper.env_or_nil("ALAYACARE_ENVIRONMENT") != "uat"
      p "CAN'T RUN REGRESSION SEEDING IN PRODUCTION"
      return
    end

    p "SEEDING DB FOR REGRESSION TEST..."

    demand_partner = DemandPartner.find_or_create_by(name: "Regression Demand Partner")
    check_progress(demand_partner)

    field_org = FieldOrg.find_or_create_by(name: "Regression Field Org")
    check_progress(field_org)

    # TODO: strictly define options?
    program = Program.find_or_create_by(name: "Regression Program", alayacare_service_code_id: "",
                                        demand_partner_id: demand_partner.id)
    check_progress(program)

    # 341 is the alayacare id of a dedicated regression form.
    service = Service.find_or_create_by(name: "Regression Service", alayacare_id: "341", duration: 30)
    check_progress(service)

    visit_type = VisitType.find_or_create_by(name: "Regression Visit Type", alayacare_id: "19")
    check_progress(visit_type)

    cancel_code = CancelCode.find_or_create_by(code: "Regression Cancel Code", alayacare_id: "13")
    check_progress(cancel_code)

    return if @something_failed

    # Associate programs, visit types, and services
    check_progress(ProgramVisitType.find_or_create_by(program_id: program.id, visit_type_id: visit_type.id))
    check_progress(ProgramService.find_or_create_by(program_id: program.id, service_id: service.id))
    check_progress(VisitTypeService.find_or_create_by(visit_type_id: visit_type.id, service_id: service.id))

    #------------------------------------------------------------
    #                       Patient
    #------------------------------------------------------------

    # NOTE: no good way for this not to hit AC, but it should be idempotent anyways.
    patient = Patient.find_or_create_by(first_name:            "Regression",
                                        last_name:             "Patient",
                                        medical_record_number: "Reg-patient-01",
                                        external_id:           "Reg-patient-external-01",
                                        date_of_birth:         Date.parse("1985-04-20"),
                                        phone_number:          "+17345467319",
                                        demand_partner_id:     demand_partner.id)
    check_progress(patient)
    return if @something_failed

    if patient.address.blank?
      check_progress(Address.create(address_line_one: "1330 Grand Ave",
                                    city:             "Des Moines",
                                    state:            "IA",
                                    zipcode:          "50309",
                                    addressable_id:   patient.id,
                                    addressable_type: "Patient"))
      # update address in AC
      patient.save
    end

    patient_program = PatientProgram.find_or_create_by(patient_id: patient.id, program_id: program.id)

    #------------------------------------------------------------
    #                     Field Providers
    #------------------------------------------------------------

    field_provider = FieldProvider.find_or_create_by(first_name: "Regression", last_name: "FP",
                                                     field_org_id: field_org.id, external_id: "Reg-fp-01")
    check_progress(field_provider)
    return if @something_failed

    if field_provider.address.blank?
      check_progress(Address.create(address_line_one: "2600 SW 9th St",
                                    city:             "Des Moines",
                                    state:            "IA",
                                    zipcode:          "50315",
                                    addressable_id:   field_provider.id,
                                    addressable_type: "FieldProvider"))
    end

    if field_provider.user.blank?
      user = User.new(email:        "regression-fp-01@medarrive.com",
                      account_type: "FieldProvider",
                      account_id:   field_provider.id)
      user.save
      check_progress(user)
    end

    field_provider2 = FieldProvider.find_or_create_by(first_name: "Second Regression", last_name: "FP",
                                                      field_org_id: field_org.id, external_id: "Reg-fp-02")
    check_progress(field_provider2)
    return if @something_failed

    if field_provider2.address.blank?
      check_progress(Address.create(address_line_one: "2507 University Ave",
                                    city:             "Des Moines",
                                    state:            "IA",
                                    zipcode:          "50311",
                                    addressable_id:   field_provider2.id,
                                    addressable_type: "FieldProvider"))
    end

    if field_provider2.user.blank?
      user = User.new(email:        "regression-fp-02@medarrive.com",
                      account_type: "FieldProvider",
                      account_id:   field_provider2.id)
      user.save
      check_progress(user)
    end

    p "REGRESSION SEEDING COMPLETE"
  end
end
