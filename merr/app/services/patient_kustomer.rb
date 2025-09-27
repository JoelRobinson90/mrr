# frozen_string_literal: true

# typed: true
class PatientKustomer
  def initialize(patient, additional_params, present_expected_fields)
    # TODO: add attribute_accesors to Patient and edit data_importer to clean this up.
    if patient.instance_of?(Patient)
      @patient = patient.attributes
      @patient["name"] = patient.full_name
      @patient["dob"] = patient.date_of_birth.in_time_zone.to_datetime.change({hour: 12}) if patient.date_of_birth
    else
      @patient = patient
    end

    @present_expected_fields = present_expected_fields
    @name = @patient["name"]
    @gender = patientSexToGender(@patient["sex"]) if @patient["sex"]
    @dob = @patient["dob"].to_datetime.change({hour: 12}) if @patient["dob"]
    @additional_params = additional_params

    # Language doesn't seem to work in Kustomer
    @preferred_language = @patient["preferred_language"] if @patient["preferred_language"]
  end

  def phones
    result = [{
      type:     "home",
      phone:    @patient["phone_number"],
      verified: true
    }.transform_keys(&:to_s)]
    if @patient["secondary_phone_number"].to_s != ""
      result.push({
        type:  "other",
        phone: @patient["secondary_phone_number"]
      }.transform_keys(&:to_s))
    end
    result
  end

  def locations
    if @patient["address"]
      return [{
        type:        "home",
        address:     @patient["address"]["address_line_one"],
        address2:    @patient["address"]["address_line_two"],
        countryName: "United States",
        regionName:  @patient["address"]["state"],
        cityName:    @patient["address"]["city"],
        zipCode:     @patient["address"]["zipcode"]
      }]
    end
    []
  end

  def externalIds
    externalIds = []
    if @patient["medical_record_number"]
      externalIds.push({externalId: @patient["medical_record_number"],
                        verified:   true})
    end
    externalIds
  end

  def patientSexToGender(s)
    if s.downcase === "male"
      "m"
    elsif s.downcase === "female"
      "f"
    end
  end

  def urls
    return [] if @patient["id"].blank?

    routes = Rails.application.routes.url_helpers
    [{type: "website", url: routes.admin_patient_url(@patient["id"], host: EnvHelper.env_or_nil("HOST"))}]
  end

  def to_hash
    patient_hash = {}

    if @present_expected_fields.include?("first_name") || @present_expected_fields.include?("middle_initial") || @present_expected_fields.include?("last_name")
      patient_hash["name"] =
        @name
    end

    patient_hash["phones"] = phones if @present_expected_fields.include?("phone_number")

    if @present_expected_fields.include?("address_line_one") && @patient["address"]
      patient_hash["locations"] = locations
    end

    patient_hash["birthdayAt"] = @dob if @present_expected_fields.include?("date_of_birth")
    patient_hash["gender"] = @gender if @present_expected_fields.include?("sex")
    patient_hash["urls"] = urls
    patient_hash["externalIds"] = externalIds

    patient_hash.merge({custom: @additional_params})
  end
end
