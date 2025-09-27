# frozen_string_literal: true

# typed: true
class AppointmentReminder < AppointmentNotification
  PROD_KUSTOMER_TAG = "6205492333c390f82eff2240"
  SANDBOX_KUSTOMER_TAG = "62054968da3be2fc9826c1ce"

  ### TODO ###
  # Once all visits are in MA:
  #   Instead of fetching from AC, get Visits from our database
  #   Get demand partner and program from visit record
  #   Remove AC_GROUP from PARTNER_DATA
  #   Remove is_a string check from NOTIFICATION_DAY_RANGE computation
  NOTIFICATION_DAY_RANGE = PARTNER_DATA.map do |(_, programs)|
    programs.map do |(_, program)|
      program[:reminder_days] unless program.is_a? String
    end
  end.flatten.compact.minmax

  def initialize(manual: false)
    super(manual)
    # @notifier = CronJob::Notification.new

    @alayacare_api = Authentication::Api.new(Authentication::AlayacareBroker)

    current_time = DateTime.now
    min_offset, max_offset = NOTIFICATION_DAY_RANGE
    timezone = "America/New_York"

    local_start = current_time.in_time_zone(timezone).beginning_of_day + min_offset.days
    local_end = current_time.in_time_zone(timezone).end_of_day + max_offset.days

    @start_time = CGI.escape(local_start.in_time_zone("UTC").iso8601)
    @end_time = CGI.escape(local_end.in_time_zone("UTC").iso8601)
  end

  def call
    # get appointments from Alayacare
    alayacare_reminders = get_reminders
    unless alayacare_reminders.success?
      report_error(result.error)
      # @notifier.slack(result.error)

      return alayacare_reminders
    end

    reminders = alayacare_reminders.payload

    # create conversations in Kustomer
    trigger_tag = EnvHelper.env_or_nil("HOST_ENV") == "prod" ? PROD_KUSTOMER_TAG : SANDBOX_KUSTOMER_TAG
    result = create_notification_conversations(reminders, trigger_tag)
    if result.success?

      message = "All #{alayacare_reminders.count} SMS Reminders were sent successfully on #{Rails.env} using #{self.class}"
      # @notifier.slack(message)

    else
      report_error(result.error)
      # @notifier.slack(result.error)
      result
    end
  end

  def schedule_url
    "scheduler/visits?start_at=#{@start_time}&end_at=#{@end_time}"
  end

  # TODO: get partner and program from visit record
  def program_config_for_ac_patient(patient_body)
    partner_key = patient_partner_key(patient_body)
    if partner_key
      programs = PARTNER_DATA[partner_key]
      if programs
        patient = Patient.where(medical_record_number: patient_body["external_id"]).first
        patient_program = patient&.programs&.first

        if patient_program
          return programs[patient_program.name]
        end
      end
    end

    nil
  end

  # TODO: get partner from visit record
  # The PARTNER_DATA AC Group key contains a string that is uniquely contained in AC group names matching the demand partner
  def patient_partner_key(patient_body)
    groups = patient_body["groups"].map {|group_hash| group_hash["name"].downcase }
    groups.each do |group|
      match = PARTNER_DATA.keys.find {|partner| group.include?(PARTNER_DATA[partner][AC_GROUP_KEY]) }
      return match if match
    end
    nil
  end

  def send_sms_reminder?(visit_body, program_data)
    return false unless program_data

    visit_start_at = Time.zone.parse(visit_body["start_at"])
    reminder_days = program_data[:reminder_days]
    return false if reminder_days.blank?

    visit_start_at.day == reminder_days.days.from_now.day
  end

  def get_reminders
    # TODO: paginate when > 100 appointments per day
    result = @alayacare_api.get(schedule_url)
    return OpenStruct.new(success?: false, error: result.body) unless result.success?

    body = JSON.parse(result.body)
    reminders = []

    visits = body["items"].reject {|visit| visit["cancelled"] }

    visits.each do |visit|
      patient_result = @alayacare_api.get("patients/clients/by_id/#{visit['client_id']}")
      report_error("Alayacare patient not found for MRN #{visit['client_id']}") && next unless patient_result.success?

      patient_body = JSON.parse(patient_result.body)
      program_data = program_config_for_ac_patient(patient_body)
      unless program_data
        report_error("Program configuration not found for patient #{visit['client_id']}") && next
      end
      next unless send_sms_reminder?(visit, program_data)

      ma_visit = Visit.where(external_id: visit["visit_id"]).first
      window_start = ma_visit.nil? ? nil : ma_visit.arrival_window_start
      window_end = ma_visit.nil? ? nil : ma_visit.arrival_window_end

      partner_display_name = program_data[:partner_display_name]
      kustomer_program = program_data[:kustomer_program]
      timezone = patient_body["timezone"]
      report_error("Alayacare patient #{visit['client_id']} is missing timezone") && next if timezone.blank?

      start_time = formatted_time(visit["start_at"], timezone, window_start, window_end)

      reminders << {
        patient_mrn:          visit["client_id"],
        start_time:           start_time,
        partner_display_name: partner_display_name,
        kustomer_program:     kustomer_program,
        conversation_name:    kustomer_note_name(start_time)
      }
    end

    OpenStruct.new(success?: true, payload: reminders)
  end

  def formatted_time(start_time_str, timezone, window_start, window_end)
    local_time = Time.zone.parse(start_time_str).in_time_zone(timezone)
    local_window_start = window_start.nil? ? nil : window_start.in_time_zone(timezone)
    local_window_end = window_end.nil? ? nil : window_end.in_time_zone(timezone)
    formatted_time_range(local_time, local_window_start, local_window_end)
  end

  def kustomer_note_name(start_time)
    if @manual
      "Manual Reminder SMS: #{start_time}"
    else
      "Appointment Reminder SMS: #{start_time}"
    end
  end
end
