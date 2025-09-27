# frozen_string_literal: true

class AppointmentConfirmation < AppointmentNotification
  PROD_KUSTOMER_TAG = "62bf3f18df98e28aa7d730d9"
  SANDBOX_KUSTOMER_TAG = "62bf3f7dab1c65329c6af699"

  def initialize(visit, manual: false)
    @visit = visit
    super(manual)
  end

  def call
    program_config = program_config_for_visit(@visit)

    if program_config.nil?
      msg = "Failed to send appointment confirmation for unknown program '#{@visit.program.name}'"
      report_error(msg)
      return OpenStruct.new({success?: false, error: msg})
    end

    return OpenStruct.new({success?: true}) unless program_config[:send_confirmations?]

    start_time = formatted_time

    confirmation = [{
      patient_mrn:          @visit.patient.external_id,
      start_time:           start_time,
      partner_display_name: program_config[:partner_display_name],
      kustomer_program:     program_config[:kustomer_program],
      conversation_name:    kustomer_note_name(start_time)
    }]

    trigger_tag = EnvHelper.env_or_nil("HOST_ENV") == "prod" ? PROD_KUSTOMER_TAG : SANDBOX_KUSTOMER_TAG
    result = create_notification_conversations(confirmation, trigger_tag)

    report_error(result.error) unless result.success?
    result
  end

  def program_config_for_visit(visit)
    program = visit.program
    partner = program.demand_partner
    return nil unless PARTNER_DATA[partner.name]

    PARTNER_DATA[partner.name][program.name]
  end

  def formatted_time
    tz = @visit.patient.address.timezone
    local_time = @visit.start_time.in_time_zone(tz)
    local_window_start = @visit.arrival_window_start? ? @visit.arrival_window_start.in_time_zone(tz) : nil
    local_window_end = @visit.arrival_window_end? ? @visit.arrival_window_end.in_time_zone(tz) : nil
    formatted_time_range(local_time, local_window_start, local_window_end)
  end

  def kustomer_note_name(start_time)
    if @manual
      "Manual Confirmation SMS: #{start_time}"
    else
      "Appointment Confirmation SMS: #{start_time}"
    end
  end
end
