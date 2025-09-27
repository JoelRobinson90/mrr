# frozen_string_literal: true

class AppointmentNotification < ApplicationService
  include Routing::Helpers

  # Temporary hardcoded SMS data
  # Structure:
  #  {
  #    "Partner 1": {
  #      AC_GROUP_KEY: string
  #      "Program 1": {
  #         partner_display_name: string
  #         reminder_days: int
  #         send_confirmations?: bool
  #         kustomer_program: string
  #      },
  #      ...
  #      "Program N": { as above }
  #    },
  #    ...
  #    "Partner N": { as above }
  #  }
  #
  # Partner 1-N keys are MA Demand Partner names
  # AC_GROUP is a lowercase string that can be used to match the demand partner with an AlayaCare group
  # Program 1-N keys are MA Program names
  # partner_display_name is the user-facing partner description (also key matched in kustomer-twilio-serverless)
  # reminder_days is number of days in advance to send an appointment reminder (comment out to disable reminders)
  # kustomer_program is the equivalent program name in Kustomer (not always the same)
  AC_GROUP_KEY = "AC_GROUP"
  PARTNER_DATA = {
    "Bright Healthcare"    => {
      AC_GROUP_KEY                               => "bright",
      "Bright 2022 CLT Area NC HCC Risk Capture" => {
        partner_display_name: "Bright HealthCare",
        reminder_days:        2,
        send_confirmations?:  true,
        kustomer_program:     "Bright 2022 CLT Area NC HCC Risk Capture"
      }
    },
    "Centene - Health Net" => {
      AC_GROUP_KEY                         => "centene",
      "Centene - CalViva Health - Vaccine" => {
        partner_display_name: "CalViva Health",
        reminder_days:        2,
        send_confirmations?:  true,
        kustomer_program:     "Centene - Health Net (Fresno/Sac, CA) - Vaccine"
      },
      "Centene - Health Net - Vaccine"     => {
        partner_display_name: "Health Net",
        reminder_days:        2,
        send_confirmations?:  true,
        kustomer_program:     "Centene - Health Net (LA, CA) - Vaccine"
      }
    },
    "Molina"               => {
      AC_GROUP_KEY                                      => "molina",
      "Molina 2021 Houston TX ED Utilization Reduction" => {
        partner_display_name: "MedArrive",
        # reminder_days:       1,     # NOTE: Molina SMS deactivated on May 16 2022
        send_confirmations?:  false, # Also not doing confirmation SMS since we move appointments around a bunch
        kustomer_program:     "Molina 2021 Houston TX ED Utilization Reduction"
      },
      "Molina 2022 Dallas TX ED Utilization Reduction"  => {
        partner_display_name: "MedArrive",
        # reminder_days:       1,     # NOTE: Molina SMS deactivated on May 16 2022
        send_confirmations?:  false, # Also not doing confirmation SMS since we move appointments around a bunch
        kustomer_program:     "Molina 2022 Dallas TX ED Utilization Reduction"
      },
      "Molina 2022 ElPaso TX ED Utilization Reduction"  => {
        partner_display_name: "MedArrive",
        # reminder_days:       1,     # NOTE: Molina SMS deactivated on May 16 2022
        send_confirmations?:  false, # Also not doing confirmation SMS since we move appointments around a bunch
        kustomer_program:     "Molina 2022 ElPaso TX ED Utilization Reduction"
      }
    },
    "Privia"               => {
      AC_GROUP_KEY                               => "privia",
      "Privia 2022 Houston area AWV Gap Closure" => {
        partner_display_name: "MedArrive",
        # reminder_days:        2,    # NOTE: Privia SMS deactivated on Nov 28 2022
        send_confirmations?:  false, # Also not doing confirmation SMS
        kustomer_program:     "Privia 2022 Houston area AWV Gap Closures"
      }
    },
    "BCBS-KC"              => {
      AC_GROUP_KEY                     => "bcbs-kc",
      "BCBS-KC 2022 HEDIS Gap Closure" => {
        partner_display_name: "Blue Cross and Blue Shield of Kansas City",
        reminder_days:        2,
        send_confirmations?:  true,
        kustomer_program:     "BCBS-KC 2022 HEDIS Gap Closure"
      }
    },
    "Optum Serve"          => {
      AC_GROUP_KEY                                     => "optumserve",
      "Optum Serve 2022 Florida Influenza Vaccination" => {
        partner_display_name: "MedArrive",
        send_confirmations?:  false, # Not doing any SMS
        kustomer_program:     "Optum Serve 2022 Florida Influenza Vaccination"
      }
    }
  }.freeze

  def initialize(manual)
    @manual = manual
    @kustomer_api = Authentication::Api.new(Authentication::KustomerBroker)
  end

  def call
    raise "this method should be overriden in a derived class"
  end

  def create_notification_conversations(notifications, trigger_tag)
    errors = []

    notifications.each do |notification|
      kustomer_id = Kustomer::Helper.get_kustomer_id(@kustomer_api, notification[:patient_mrn])
      report_error("Kustomer patient not found with MRN #{notification[:patient_mrn]}") && next if kustomer_id.blank?

      body = {
        customer: kustomer_id,
        name:     notification[:conversation_name],
        custom:   {
          appointmentTimeStr:    notification[:start_time],
          partnerDisplayNameStr: notification[:partner_display_name],
          regardingProgramStr:   notification[:kustomer_program]
        },
        status:   "done"
      }
      response = Kustomer::Helper.parse_response(@kustomer_api.post("conversations", body))

      # Twilio script is looking for tags ADDED to conversations, so we need to update the one we just created.
      if response.success?
        unless @manual
          body = JSON.parse(response.body)
          response = Kustomer::Helper.parse_response(@kustomer_api.put("conversations/#{body['data']['id']}",
                                                                       {tags: [trigger_tag]}))

          errors << response.errors unless response.success?
        end
      else
        errors << response.errors
      end
    end

    if errors.present?
      OpenStruct.new({success?: false, error: errors.join(", ")})
    else
      OpenStruct.new({success?: true})
    end
  end

  def formatted_time_range(local_start_time, local_arrival_window_start, local_arrival_window_end)
    time = round_time_15(local_start_time)
    time_format = "%-l:%M%p"

    window_start = local_arrival_window_start.nil? ? (time - 30.minutes) : local_arrival_window_start
    window_end = local_arrival_window_end.nil? ? (time + 30.minutes) : local_arrival_window_end

    date_str = time.strftime("%A, %b %-d %Y")

    "#{date_str}. The provider will arrive between #{window_start.strftime(time_format)} and #{window_end.strftime(time_format)}"
  end

  def report_error(error)
    Sentry.capture_message(error)
    true
  end
end
