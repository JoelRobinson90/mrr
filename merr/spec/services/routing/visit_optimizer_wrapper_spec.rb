# typed: true
# frozen_string_literal: true

require "rails_helper"

def add_standard_resource(options)
  options.each do |option|
    option[:resources] = [
      {
        resource_id: option[:fp_id],
        in_home:     true,
        start_time: option[:start_time],
        end_time: option[:end_time],
        name: option[:fp_name],
        provider_role: "field_provider",
        preferred: false
      }
    ]
  end
  options
end

RSpec.describe Routing::VisitOptimizerWrapper, type: :request do
  let(:service) { Routing::VisitOptimizerWrapper }

  let(:patient) do
    build(:patient, address: build(:address, latitude: "40.747795", longitude: "-73.985071", zipcode: "98103"))
  end

  context "with shifts and blockers" do
    before do
      Timecop.freeze(Time.zone.local(2021, 10, 20, 12))
    end

    after do
      Timecop.return
    end

    let!(:target_date) { Date.parse("2021-11-01") }
    let!(:next_day) { target_date + 1.day }

    let!(:demand_partner) { create(:demand_partner, short_name: "Demand Partner name") }

    let!(:program_options) do
      {
        minutes_of_buffer_time:              15,
        max_results:                         nil,
        hours_before_first_option:           10,
        max_straight_line_distance_in_miles: 300,
        drive_weight:                        80,
        proximity_weight:                    10,
        utilization_weight:                  10,
        min_shift_length_in_hours:           8.0,
        arrival_window_offset_minutes:       5,
        demand_partner:                      demand_partner
      }
    end

    let(:program) do
      create(:program, program_options)
    end

    let(:test_visits) do
      [
        {
          fp_id:      "5",
          location:   "40.6860072,-73.851524",
          start_time: target_date + 10.hours,
          end_time:   target_date + 11.hours
        },
        {
          fp_id:      "5",
          location:   "40.6860072,-73.851524",
          start_time: target_date + 11.hours,
          end_time:   target_date + 12.hours
        },
        {
          fp_id:      "5",
          location:   "40.6860072,-73.851524",
          start_time: target_date + 17.hours,
          end_time:   target_date + 18.hours
        }

      ]
    end

    let(:test_shifts) do
      [
        {
          fp_id:         "5",
          fp_name:       "Test FP",
          provider_role: "field_provider",
          location:      "40.659569,-73.933783",
          location_name: "Dallas #{demand_partner.short_name} - central",
          start_time:    target_date + 6.hours,
          end_time:      target_date + 18.hours
        },
        {
          fp_id:         "6",
          fp_name:       "Example FP",
          provider_role: "field_provider",
          location:      "40.659569,-73.933783",
          location_name: "Dallas #{demand_partner.short_name.upcase} - north",
          start_time:    next_day + 8.hours,
          end_time:      next_day + 17.hours
        }
      ]
    end

    it "works with grace period" do
      program.update(minutes_of_buffer_time: -60, max_grace_period: 15)

      test_shifts = [
        {
          fp_id:         "5",
          fp_name:       "Test FP",
          provider_role: "field_provider",
          location:      "40.659569,-73.933783",
          location_name: demand_partner.short_name,
          start_time:    target_date + 6.hours,
          end_time:      target_date + 9.hours
        }
      ]

      test_visits = [
        {
          fp_id:      "5",
          location:   "40.6860072,-73.851524",
          start_time: target_date + 6.hours,
          end_time:   target_date + 7.hours
        },
        {
          fp_id:      "5",
          location:   "40.6860072,-73.851524",
          start_time: target_date + 8.hours,
          end_time:   target_date + 9.hours
        }
      ]

      expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                      payload:  test_visits}))
      expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true, payload: test_shifts}))

      # 15 minutes short to fit visit duration
      result = service.call(patient, target_date, target_date + 2.days, 75, program_id: program.id)

      expect(result.success?).to be true

      option = result.payload[0]

      # scheduled halfway overlaping begining visit and ending visit
      expect(option[:start_time]).to eq Time.zone.parse("2021-11-01 06:53:00.000000000 +0000")
      expect(option[:grace_period]).to eq 15

      log = SchedulerLog.last

      expect(log[:max_grace_period]).to eq 15
      expect(log[:grace_period_options_count]).to eq 1
    end

    it "prevents virtual provider overlap" do
      # virtual provider offset prevents any visits in the program from starting
      # at the same time, regardless of shift.
      program.update(virtual_provider_offset: 30, minutes_of_buffer_time: 0)

      location = "#{patient.address.latitude},#{patient.address.longitude}"

      test_shifts = [
        {
          fp_id:         "5",
          fp_name:       "Test FP",
          provider_role: "field_provider",
          location:      location,
          location_name: demand_partner.short_name,
          start_time:    target_date + 6.hours,
          end_time:      target_date + 7.hours
        },
        {
          fp_id:         "6",
          fp_name:       "Example FP",
          provider_role: "field_provider",
          location:      location,
          location_name: demand_partner.short_name,
          start_time:    target_date + 6.hours,
          end_time:      target_date + 7.hours
        }
      ]

      test_visits = [
        {
          fp_id:      "5",
          location:   location,
          start_time: target_date + 6.hours,
          end_time:   target_date + 7.hours,
          program_id: program.id
        }
      ]

      expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                      payload:  test_visits}))
      expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true, payload: test_shifts}))

      # This visit should fit in the second shift, but it would have to overlap the 30 minute virtual provider buffer.
      result = service.call(patient, target_date, target_date + 2.days, 45, program_id: program.id)

      expect(result.success?).to be true

      expect(result.payload.length).to eq(0)
    end

    it "filters out shifts not belonging to program demand partner" do
      test_shifts = [
        {
          fp_id:         "5",
          fp_name:       "Test FP",
          provider_role: "field_provider",
          location:      "40.659569,-73.933783",
          location_name: "WRONG NAME",
          start_time:    target_date + 6.hours,
          end_time:      target_date + 9.hours
        }
      ]

      expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true, payload: []}))
      expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true, payload: test_shifts}))

      # 15 minutes short to fit visit duration
      result = service.call(patient, target_date, target_date + 2.days, 30, program_id: program.id)

      expect(result.success?).to be true

      expect(result.payload.length).to eq(0)
    end

    context "with service_area" do
      let!(:patient) do
        create(:patient, address: build(:address, latitude: "40.747795", longitude: "-73.985071", zipcode: "98103"))
      end

      let!(:service_area) { create(:service_area, name: "Central") }
      let!(:geo_cohort) { create(:geo_cohort, service_area: service_area, name: "test") }
      let!(:patient_geo) do
        create(:patient_geo, patient: patient, program: program, service_area: service_area, geo_cohort: geo_cohort)
      end

      let(:test_shifts) do
        [
          {
            fp_id:         "5",
            fp_name:       "Test FP",
            provider_role: "field_provider",
            location:      "40.659569,-73.933783",
            location_name: "#{demand_partner.short_name} - WRONG SERVICE AREA",
            start_time:    target_date + 6.hours,
            end_time:      target_date + 9.hours
          }
        ]
      end

      before do
        program.update(enforce_service_area: true)
      end

      it "enforce_service_area filters out shifts in different service area" do
        expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true, payload: []}))
        expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                  payload:  test_shifts}))

        result = service.call(patient, target_date, target_date + 2.days, 30, program_id: program.id)

        expect(result.success?).to be true
        expect(result.payload.length).to eq(0)
      end

      it "enforce_service_area allows shifts in matched service area" do
        test_shifts[0][:location_name] = "#{demand_partner.short_name} - CENTRAL"

        expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true, payload: []}))
        expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                  payload:  test_shifts}))

        result = service.call(patient, target_date, target_date + 2.days, 30, program_id: program.id)

        expect(result.success?).to be true
        expect(!result.payload.empty?).to be true
      end
    end

    context "with existing visit" do
      let(:test_shifts) do
        [
          {
            fp_id:         "5",
            fp_name:       "Test FP",
            provider_role: "field_provider",
            location:      "40.747794,-73.985073",
            location_name: demand_partner.short_name,
            start_time:    target_date + 6.hours,
            end_time:      target_date + 7.hours
          }
        ]
      end

      let(:test_visits) do
        [
          {
            visit_id:           "TEST_ID",
            fp_id:              "5",
            location:           "40.6860072,-73.851524",
            start_time:         target_date + 6.hours,
            end_time:           target_date + 7.hours
          }
        ]
      end

      it "conflicts with existing visit if ignore_existing_visit_conflicts is false" do

        expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                        payload:  test_visits}))
        expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true, payload: test_shifts}))

        # Doesn't find option because blocked by existing visit
        result = service.call(patient, target_date, target_date + 2.days, 45,
                              program_id: program.id, existing_visit_id: "TEST_ID",
                              ignore_existing_visit_conflicts: false)

        expect(result.success?).to be true
        expect(result.payload.empty?).to be true
      end

      it "ignores existing visit by default" do

        expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                        payload:  test_visits}))
        expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true, payload: test_shifts}))

        # Reschedules should ignore this
        program.update(hours_before_first_option: 10_000)

        # Should find option if existing visit is ignored
        result = service.call(patient, target_date, target_date + 2.days, 45,
                              program_id: program.id, existing_visit_id: "TEST_ID")

        expect(result.success?).to be true
        expect(result.payload.empty?).to be false

        option = result.payload[0]

        # Option that would have overlaped with existing visit
        expect(option[:start_time]).to eq(Time.zone.parse("2021-11-01 06:00:00.000000000 +0000"))
        expect(option[:end_time]).to eq(Time.zone.parse("2021-11-01 06:45:00.000000000 +0000"))

        log = SchedulerLog.last

        expect(log[:rescheduling]).to be true
      end
    end

    it "works with negative buffer times" do
      # this should eliminate all drive times
      program.update(minutes_of_buffer_time: -60)

      expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                      payload:  test_visits}))
      expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true, payload: test_shifts}))

      result = service.call(patient, target_date, target_date + 2.days, 60, program_id: program.id)

      expect(result.success?).to be true

      payload = result.payload

      payload = payload.pluck(:start_time).sort

      # NOTE: buffer ignored at beginning and end of shift
      expected = [
        Time.zone.parse("2021-11-01 06:39:00.000000000 +0000"), # first possible time
        Time.zone.parse("2021-11-01 09:00:00.000000000 +0000"), # right before existing 10am
        Time.zone.parse("2021-11-01 12:00:00.000000000 +0000"), # right after existing 11-12
        Time.zone.parse("2021-11-01 16:00:00.000000000 +0000"), # right before existing 17
        Time.zone.parse("2021-11-02 08:39:00.000000000 +0000"), # drive time after shift start
        Time.zone.parse("2021-11-02 10:39:00.000000000 +0000"), # non-contiguous 1 hour later
        Time.zone.parse("2021-11-02 12:39:00.000000000 +0000"), # non-contiguous 1 hour later
        Time.zone.parse("2021-11-02 15:20:00.000000000 +0000") # right before end of shift plus drive
      ]

      expect(payload).to eq(expected)
    end

    it "finds availible options" do
      expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                      payload:  test_visits}))
      expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true, payload: test_shifts}))
      patient.address.update(timezone: "UTC")

      # need some weight to calculate shift shortening penalty score
      program.update(shift_shortening_penalty_weight: 1, utilization_weight: 9)

      result = service.call(patient, target_date, target_date + 2.days, 60, program_id: program.id)

      expect(result.success?).to be true

      payload = result.payload

      # strip UUIDs for testing
      expect(payload.first[:run_id].present?).to be true
      payload = payload.map {|option| option.except(:run_id) }

      # one option before mid-day visits on day one, because that's all that will fit.
      # two options after mid-day visits on day one, both contiguous.
      # four options for the open slot on day two, beginning and end of shift, and two non-contiguous.
      # ordered by drive time, but non-contiguous options last.
      expected = [
        {
          fp_id:                          "5",
          fp_name:                        "Test FP",
          arrival_window_start:           Time.zone.parse("2021-11-01 12:40:00 +0000"),
          arrival_window_end:             Time.zone.parse("2021-11-01 12:50:00 +0000"),
          cx_start:                       Time.zone.parse("2021-11-01 12:45:00 +0000"),
          cx_end:                         Time.zone.parse("2021-11-01 13:45:00 +0000"),
          start_time:                     Time.zone.parse("2021-11-01 12:45:00 +0000"),
          end_time:                       Time.zone.parse("2021-11-01 13:45:00 +0000"),
          grace_period:                   0,
          expected_drive:                 30,
          total_score:                    70,
          drive_score:                    75,
          proximity_score:                32,
          utilization_score:              67,
          shift_shortening_penalty_score: 41,
          rank_category:                  :high
        },
        {
          fp_id:                          "5",
          fp_name:                        "Test FP",
          arrival_window_start:           Time.zone.parse("2021-11-01 08:10:00 +0000"),
          arrival_window_end:             Time.zone.parse("2021-11-01 08:20:00 +0000"),
          cx_start:                       Time.zone.parse("2021-11-01 08:15:00 +0000"),
          cx_end:                         Time.zone.parse("2021-11-01 09:15:00 +0000"),
          start_time:                     Time.zone.parse("2021-11-01 08:14:00 +0000"),
          end_time:                       Time.zone.parse("2021-11-01 09:14:00 +0000"),
          grace_period:                   0,
          expected_drive:                 31,
          total_score:                    69,
          drive_score:                    74,
          proximity_score:                34,
          utilization_score:              67,
          shift_shortening_penalty_score: 41,
          rank_category:                  :medium
        },
        {
          fp_id:                          "5",
          fp_name:                        "Test FP",
          arrival_window_start:           Time.zone.parse("2021-11-01 15:10:00 +0000"),
          arrival_window_end:             Time.zone.parse("2021-11-01 15:20:00 +0000"),
          cx_start:                       Time.zone.parse("2021-11-01 15:15:00 +0000"),
          cx_end:                         Time.zone.parse("2021-11-01 16:15:00 +0000"),
          start_time:                     Time.zone.parse("2021-11-01 15:14:00 +0000"),
          end_time:                       Time.zone.parse("2021-11-01 16:14:00 +0000"),
          grace_period:                   0,
          expected_drive:                 31,
          total_score:                    69,
          drive_score:                    74,
          proximity_score:                31,
          utilization_score:              67,
          shift_shortening_penalty_score: 41,
          rank_category:                  :medium
        },
        {
          fp_id:                          "6",
          fp_name:                        "Example FP",
          arrival_window_start:           Time.zone.parse("2021-11-02 08:40:00 +0000"),
          arrival_window_end:             Time.zone.parse("2021-11-02 08:50:00 +0000"),
          cx_start:                       Time.zone.parse("2021-11-02 08:45:00 +0000"),
          cx_end:                         Time.zone.parse("2021-11-02 09:45:00 +0000"),
          start_time:                     Time.zone.parse("2021-11-02 08:38:00 +0000"),
          end_time:                       Time.zone.parse("2021-11-02 09:38:00 +0000"),
          grace_period:                   0,
          expected_drive:                 38,
          total_score:                    67,
          drive_score:                    68,
          proximity_score:                22,
          utilization_score:              100,
          shift_shortening_penalty_score: 100,
          rank_category:                  :medium
        },
        {
          fp_id:                          "6",
          fp_name:                        "Example FP",
          arrival_window_start:           Time.zone.parse("2021-11-02 15:10:00 +0000"),
          arrival_window_end:             Time.zone.parse("2021-11-02 15:20:00 +0000"),
          cx_start:                       Time.zone.parse("2021-11-02 15:15:00 +0000"),
          cx_end:                         Time.zone.parse("2021-11-02 16:15:00 +0000"),
          start_time:                     Time.zone.parse("2021-11-02 15:18:00 +0000"),
          end_time:                       Time.zone.parse("2021-11-02 16:18:00 +0000"),
          grace_period:                   0,
          expected_drive:                 42,
          total_score:                    64,
          drive_score:                    65,
          proximity_score:                18,
          utilization_score:              100,
          shift_shortening_penalty_score: 100,
          rank_category:                  :medium
        },
        # non-contiguous options
        {
          fp_id:                          "6",
          fp_name:                        "Example FP",
          arrival_window_start:           Time.zone.parse("2021-11-02 10:40:00 +0000"),
          arrival_window_end:             Time.zone.parse("2021-11-02 10:50:00 +0000"),
          cx_start:                       Time.zone.parse("2021-11-02 10:45:00 +0000"),
          cx_end:                         Time.zone.parse("2021-11-02 11:45:00 +0000"),
          start_time:                     Time.zone.parse("2021-11-02 10:38:00 +0000"),
          end_time:                       Time.zone.parse("2021-11-02 11:38:00 +0000"),
          grace_period:                   0,
          expected_drive:                 40,
          total_score:                    49,
          drive_score:                    47,
          proximity_score:                21,
          utilization_score:              100,
          shift_shortening_penalty_score: 100,
          rank_category:                  :low
        },
        {
          fp_id:                          "6",
          fp_name:                        "Example FP",
          arrival_window_start:           Time.zone.parse("2021-11-02 12:40:00 +0000"),
          arrival_window_end:             Time.zone.parse("2021-11-02 12:50:00 +0000"),
          cx_start:                       Time.zone.parse("2021-11-02 12:45:00 +0000"),
          cx_end:                         Time.zone.parse("2021-11-02 13:45:00 +0000"),
          start_time:                     Time.zone.parse("2021-11-02 12:38:00 +0000"),
          end_time:                       Time.zone.parse("2021-11-02 13:38:00 +0000"),
          grace_period:                   0,
          expected_drive:                 40,
          total_score:                    49,
          drive_score:                    47,
          proximity_score:                20,
          utilization_score:              100,
          shift_shortening_penalty_score: 100,
          rank_category:                  :low
        }
      ]

      expect(payload).to eq(add_standard_resource(expected))

      scheduler_log = SchedulerLog.last
      expect(scheduler_log.disposition).to eq("options_shown")
      expect(scheduler_log.options_without_any_preferred_provider_count).to eq(payload.length)
      expect(scheduler_log.options_without_full_preferred_provider_count).to eq(payload.length)

      expect(result.message).to eq("Visit options fetched")
    end

    it "finds availible options within arrival window" do
      test_shifts = [
        {
          fp_id:         "5",
          fp_name:       "Test FP",
          provider_role: "field_provider",
          location:      "40.659569,-73.933783",
          location_name: demand_partner.short_name,
          start_time:    target_date + 6.hours,
          end_time:      target_date + 18.hours
        },
        {
          fp_id:         "6",
          fp_name:       "Example FP",
          provider_role: "field_provider",
          location:      "40.659569,-73.933783",
          location_name: demand_partner.short_name,
          start_time:    target_date + 8.hours,
          end_time:      target_date + 17.hours
        }
      ]
      expect(::Routing::GetAppointments).to receive(:call).twice.and_return(OpenStruct.new({success?: true,
                                                                                            payload:  test_visits}))
      expect(::Routing::GetShifts).to receive(:call).twice.and_return(OpenStruct.new({success?: true,
                                                                                      payload:  test_shifts}))
      patient.address.update(timezone: "UTC")

      arrival_window = [Time.zone.parse("2021-11-01 11:00:00 +0000"), Time.zone.parse("2021-11-01 14:00:00 +0000")]

      result = service.call(patient, target_date, target_date + 1.day, 60, program_id:     program.id,
                                                                           arrival_window: arrival_window)

      expect(result.success?).to be true

      payload = result.payload

      # strip UUIDs for testing
      payload = payload.map {|option| option.except(:run_id) }

      # Test FP has a visit until noon, so can have a contiguous visit right after.
      # Example FP should pick the best time from anywhere in the arrival window.
      # There should only be one option per FP.
      expected = [
        {
          fp_id:                          "5",
          fp_name:                        "Test FP",
          arrival_window_start:           Time.zone.parse("2021-11-01 12:55:00.000000000 +0000"),
          arrival_window_end:             Time.zone.parse("2021-11-01 13:05:00.000000000 +0000"),
          cx_start:                       Time.zone.parse("2021-11-01 13:00:00.000000000 +0000"),
          cx_end:                         Time.zone.parse("2021-11-01 14:00:00.000000000 +0000"),
          start_time:                     Time.zone.parse("2021-11-01 13:00:00.000000000 +0000"),
          end_time:                       Time.zone.parse("2021-11-01 14:00:00.000000000 +0000"),
          grace_period:                   0,
          expected_drive:                 45,
          total_score:                    59,
          drive_score:                    63,
          proximity_score:                21,
          utilization_score:              67,
          shift_shortening_penalty_score: 100,
          rank_category:                  :high
        },
        {
          fp_id:                          "6",
          fp_name:                        "Example FP",
          arrival_window_start:           Time.zone.parse("2021-11-01 13:55:00.000000000 +0000"),
          arrival_window_end:             Time.zone.parse("2021-11-01 14:05:00.000000000 +0000"),
          cx_start:                       Time.zone.parse("2021-11-01 14:00:00.000000000 +0000"),
          cx_end:                         Time.zone.parse("2021-11-01 15:00:00.000000000 +0000"),
          start_time:                     Time.zone.parse("2021-11-01 14:00:00.000000000 +0000"),
          end_time:                       Time.zone.parse("2021-11-01 15:00:00.000000000 +0000"),
          grace_period:                   0,
          expected_drive:                 40,
          total_score:                    49,
          drive_score:                    47,
          proximity_score:                20,
          utilization_score:              100,
          shift_shortening_penalty_score: 100,
          rank_category:                  :low
        }
      ]

      expect(payload).to eq(add_standard_resource(expected))

      expect(result.message).to eq("Visit options fetched")

      # With only one start time allowed

      arrival_window = [Time.zone.parse("2021-11-01 12:00:00 +0000"), Time.zone.parse("2021-11-01 12:00:00 +0000")]

      result = service.call(patient, target_date, target_date + 1.day, 60, program_id:     program.id,
                                                                           arrival_window: arrival_window)

      expect(result.success?).to be true

      payload = result.payload

      # strip UUIDs for testing
      payload = payload.map {|option| option.except(:run_id) }

      expected = [
        {
          fp_id:                          "6",
          fp_name:                        "Example FP",
          arrival_window_start:           Time.zone.parse("2021-11-01 11:55:00.000000000 +0000"),
          arrival_window_end:             Time.zone.parse("2021-11-01 12:05:00.000000000 +0000"),
          cx_start:                       Time.zone.parse("2021-11-01 12:00:00.000000000 +0000"),
          cx_end:                         Time.zone.parse("2021-11-01 13:00:00.000000000 +0000"),
          start_time:                     Time.zone.parse("2021-11-01 12:00:00.000000000 +0000"),
          end_time:                       Time.zone.parse("2021-11-01 13:00:00.000000000 +0000"),
          grace_period:                   0,
          expected_drive:                 40,
          total_score:                    49,
          drive_score:                    47,
          proximity_score:                22,
          utilization_score:              100,
          shift_shortening_penalty_score: 100,
          rank_category:                  :high
        }
      ]

      expect(payload).to eq(add_standard_resource(expected))
    end

    context "without any shifts" do
      let(:test_shifts) { [] }

      it "returns error message about shifts" do
        expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                        payload:  test_visits}))
        expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                  payload:  test_shifts}))

        result = service.call(patient, target_date, target_date + 2.days, 60)

        expect(result.success?).to be true
        expect(result.payload).to eq([])
        expect(result.message).to eq("No shifts scheduled within 300 miles of patient. No shifts for field providers.")

        scheduler_log = SchedulerLog.last
        expect(scheduler_log.disposition).to eq("no_shifts")
        expect(scheduler_log.blocking_roles).to eq("field_provider")
      end
    end

    context "without open slots" do
      let(:test_shifts) do
        [
          {
            fp_id:         "5",
            fp_name:       "Test FP",
            provider_role: "field_provider",
            location:      "40.659569,-73.933783",
            location_name: demand_partner.short_name,
            start_time:    target_date + 9.hours,
            end_time:      target_date + 11.hours
          }
        ]
      end

      it "returns error message about open slots" do
        expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                        payload:  test_visits}))
        expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                  payload:  test_shifts}))

        # There's 1 hour free, but 55 minutes plus buffer won't fit.
        result = service.call(patient, target_date, target_date + 2.days, 55)

        expect(result.success?).to be true
        expect(result.payload).to eq([])
        expect(result.message).to eq("No open time slots found for this area. No slots for field providers.")

        scheduler_log = SchedulerLog.last
        expect(scheduler_log.disposition).to eq("no_slots")
        expect(scheduler_log.blocking_roles).to eq("field_provider")
      end
    end

    context "without drivable slots" do
      let(:test_shifts) do
        [
          {
            fp_id:         "5",
            fp_name:       "Test FP",
            provider_role: "field_provider",
            location:      "40.659569,-73.933783",
            location_name: demand_partner.short_name,
            start_time:    target_date + 9.hours,
            end_time:      target_date + 11.hours
          }
        ]
      end

      it "returns error message about drive time" do
        expect(::Routing::GetAppointments).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                        payload:  test_visits}))
        expect(::Routing::GetShifts).to receive(:call).and_return(OpenStruct.new({success?: true,
                                                                                  payload:  test_shifts}))

        # 40 minute drive plus 15 min buffer barely fits in one hour slot, so blocked for drive time.
        result = service.call(patient, target_date, target_date + 2.days, 40)

        expect(result.success?).to be true
        expect(result.payload).to eq([])
        expect(result.message).to eq("No open time slots available for this patient due to drive times.")

        scheduler_log = SchedulerLog.last
        expect(scheduler_log.disposition).to eq("no_options")
      end
    end
  end

  context "using helper function" do
    let(:instance) { service.new(patient, Date.today, Date.today, 45) }

    context "with preferred providers" do
      let(:field_provider) { create(:field_provider) }
      let!(:provider_preference) { create(:provider_preference, patient: patient, field_provider: field_provider)}

      it "creates preferred_provider parameter" do
        expect(instance.get_preferred_providers(patient)).to eq([field_provider.external_id])
      end
    end
  end
end
