# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::VisitOptimizer, type: :request do
  let(:service) { Routing::VisitOptimizer }
  let!(:target_date) { Date.parse("2021-11-01") }

  context "with inputs" do
    before do
      Timecop.freeze(Time.zone.local(2021, 10, 20, 12))
    end

    after do
      Timecop.return
    end

    let!(:parameters) do
      {
        start_date:     target_date,
        end_date:       target_date,
        visit_duration: 30,
        visit_geo:      "29.658141,-95.355308"
      }
    end

    let!(:options) do
      {
        hours_before_first_option:        0,
        max_grace_period:                 0,
        minutes_of_buffer_time:           0,
        drive_weight:                     25,
        proximity_weight:                 25,
        utilization_weight:               25,
        shift_shortening_penalty_weight:  25,
        high_rank_percentile_threshold:   0,
        medium_rank_percentile_threshold: 0,
        high_rank_absolute_threshold:     0,
        medium_rank_absolute_threshold:   0
      }
    end

    context "single resource type" do
      let(:test_visits) do
        [
          {
            fp_id:      "5",
            location:   "29.717654,-95.387073",
            start_time: target_date + 10.hours,
            end_time:   target_date + 11.hours
          }
        ]
      end

      let(:test_shifts) do
        [
          {
            provider_role: "field_provider",
            fp_id:         "5",
            location:      "29.734886,-95.322579",
            start_time:    target_date + 8.hours,
            end_time:      target_date + 13.hours
          }
        ]
      end

      it "returns options" do
        result = service.call(test_shifts, test_visits, parameters, options)

        expect(result.success?).to be true

        expect(result.payload[:options].length).to eq 2
        expect(!result.payload[:slots].empty?).to be true
        expect(result.payload[:initial_slots_count] > 0).to be true
        expect(result.payload[:pre_merge_slots_count_by_role]["field_provider"] > 0).to be true
        expect(result.payload[:shifts_count_by_role]["field_provider"] > 0).to be true

        expect(result.payload[:options].length).to eq 2
      end

      it "gets drive times with valhalla" do
        options[:use_custom_drive_time_service] = true

        result = service.call(test_shifts, test_visits, parameters, options)

        expect(result.success?).to be true

        expect(result.payload[:options].length).to eq 2
        expect(!result.payload[:slots].empty?).to be true
        expect(result.payload[:initial_slots_count] > 0).to be true
      end
    end

    context "multiple resource types" do
      let!(:field_provider_id) { "fp_1" }
      let!(:social_worker_id) { "sw_1" }
      let(:test_visits) do
        [
          {
            fp_id:      field_provider_id,
            location:   "29.717654,-95.387073",
            start_time: target_date + 14.hours,
            end_time:   target_date + 15.hours
          },
          {
            fp_id:      social_worker_id,
            start_time: target_date + 12.hours,
            end_time:   target_date + 13.hours
          }
        ]
      end

      let(:test_shifts) do
        [
          {
            provider_role: "field_provider",
            fp_id:         field_provider_id,
            location:      "29.734886,-95.322579",
            start_time:    target_date + 11.hours,
            end_time:      target_date + 16.hours
          },
          {
            provider_role: "social_worker",
            fp_id:         social_worker_id,
            start_time:    target_date + 10.hours,
            end_time:      target_date + 15.hours
          }
        ]
      end

      let(:resource_requirements) do
        [
          {
            provider_role: "field_provider",
            in_home:       true,
            duration:      30,
            offset:        0
          },
          {
            provider_role: "social_worker",
            in_home:       false,
            duration:      15,
            offset:        15
          }
        ]
      end

      let(:preferred_providers) { [field_provider_id] }

      it "doesn't return options if any requirement can not be met" do
        # this requirement has no shifts
        unsatisfiable_requirement = {
          provider_role: "nurse_practitioner",
          in_home:       true,
          duration:      15,
          offset:        15
        }

        parameters[:resource_requirements] = resource_requirements.prepend(unsatisfiable_requirement)
        parameters[:visit_duration] = 30

        result = service.call(test_shifts, test_visits, parameters, options)

        expect(result.success?).to be true

        expect(result.payload[:initial_slots_count]).to eq(0)
        expect(result.payload[:pre_merge_slots_count_by_role]["nurse_practitioner"]).to eq(0)
        expect(result.payload[:shifts_count_by_role]["nurse_practitioner"]).to eq(0)

        options = result.payload[:options]
        expect(options.length).to eq 0
      end

      it "returns options" do
        parameters[:resource_requirements] = resource_requirements
        parameters[:visit_duration] = 30
        parameters[:preferred_providers] = preferred_providers

        result = service.call(test_shifts, test_visits, parameters, options)

        expect(result.success?).to be true

        expect(result.payload[:initial_slots_count]).to eq(2)
        %w[field_provider social_worker].each do |role|
          expect(result.payload[:pre_merge_slots_count_by_role][role] > 0).to be true
          expect(result.payload[:shifts_count_by_role][role]).to eq(1)
        end

        slots = result.payload[:slots]

        expect(slots[0][:start_time]).to eq(target_date + 11.hours)
        expect(slots[0][:end_time]).to eq(target_date + 12.hours)
        expect(slots[0][:origin_buffer]).to eq 0
        expect(slots[0][:destination_buffer]).to eq(-120)
        expect(slots[0][:resources].pluck(:resource_id)).to eq %w[fp_1 sw_1]

        expect(slots[1][:start_time]).to eq(target_date + 12.hours + 45.minutes)
        expect(slots[1][:end_time]).to eq(target_date + 14.hours)
        expect(slots[1][:origin_buffer]).to eq(-105) # 1hr 45min to start of in_home shift
        expect(slots[1][:destination_buffer]).to eq(0)
        expect(slots[1][:resources].pluck(:resource_id)).to eq %w[fp_1 sw_1]

        options = result.payload[:options]

        expect(options.length).to eq 2

        resources = options[0][:resources]

        expect(resources.length).to eq 2
        expect(resources[0][:resource_id]).to eq "fp_1"
        expect(resources[0][:in_home]).to be true
        expect(resources[0][:start_time]).to eq options[0][:start_time]
        expect(resources[0][:end_time]).to eq options[0][:end_time]
        expect(resources[0][:preferred]).to eq true
        expect(resources[0][:provider_role]).to eq "field_provider"

        expect(resources[1][:resource_id]).to eq "sw_1"
        expect(resources[1][:in_home]).to be false
        expect(resources[1][:start_time]).to eq options[0][:start_time] + 15.minutes
        expect(resources[1][:end_time]).to eq options[0][:end_time]
        expect(resources[1][:preferred]).to eq false
        expect(resources[1][:provider_role]).to eq "social_worker"
      end

      context "with virtual only providers" do
        let(:virtual_resource_requirements) { resource_requirements.map {|rr| rr.update(in_home: false) }}

        let(:virtual_test_shifts) { test_shifts.map {|shift| shift.except(:location) }}

        it "returns options" do

          parameters[:resource_requirements] = virtual_resource_requirements
          parameters[:visit_duration] = 30

          result = service.call(virtual_test_shifts, test_visits, parameters, options)

          expect(result.success?).to be true

          expect(result.payload[:initial_slots_count]).to eq(2)

          slots = result.payload[:slots]

          expect(slots[0][:start_time]).to eq(target_date + 11.hours)
          expect(slots[0][:end_time]).to eq(target_date + 12.hours)
          expect(slots[0][:origin_buffer]).to eq 0
          expect(slots[0][:destination_buffer]).to eq(0)
          expect(slots[0][:resources].pluck(:resource_id)).to eq %w[fp_1 sw_1]

          options = result.payload[:options]

          expect(options.length).to eq 2
        end
      end
    end
  end

  context "using a helper function" do
    let(:slot) do
      {
        fp_id:                  "5",
        start_time:             Time.zone.parse("2021-11-1 1:00"),
        end_time:               Time.zone.parse("2021-11-1 3:00"),
        origin_drive_time:      15,
        destination_drive_time: 20,
        grace_period:           0,
        origin_buffer:          0,
        destination_buffer:     0,
        resources:              [{resource_id: "5", in_home: true}]
      }
    end

    let!(:parameters) do
      {
        start_date:     target_date,
        end_date:       target_date,
        visit_duration: 60
      }
    end
    let!(:options) do
      {
        hours_before_first_option: 0,
        max_grace_period:          0,
        minutes_of_buffer_time:    15
      }
    end

    let(:instance) { service.new([], [], parameters, options) }

    it "merges slots" do
      fp_slots = [
        {
          fp_id:              "fp_1",
          start_time:         Time.zone.parse("2021-11-1 2:00"),
          end_time:           Time.zone.parse("2021-11-1 5:00"),
          origin_buffer:      0,
          destination_buffer: 0,
          resources:          [{resource_id: "fp_1", in_home: true}]
        },
        {
          fp_id:              "fp_2",
          start_time:         Time.zone.parse("2021-11-1 5:00"),
          end_time:           Time.zone.parse("2021-11-1 6:00"),
          origin_buffer:      5,
          destination_buffer: 5,
          resources:          [{resource_id: "fp_2", in_home: true}]
        }
      ]

      sw_slots = [
        {
          fp_id:              "sw_1",
          start_time:         Time.zone.parse("2021-11-1 1:00"),
          end_time:           Time.zone.parse("2021-11-1 3:00"),
          origin_buffer:      0,
          destination_buffer: 0,
          resources:          [{resource_id: "sw_1", in_home: false}]
        },
        {
          fp_id:              "sw_2",
          start_time:         Time.zone.parse("2021-11-1 3:00"),
          end_time:           Time.zone.parse("2021-11-1 4:00"),
          origin_buffer:      0,
          destination_buffer: 0,
          resources:          [{resource_id: "sw_2", in_home: false}]
        },
        {
          fp_id:              "sw_3",
          start_time:         Time.zone.parse("2021-11-1 4:00"),
          end_time:           Time.zone.parse("2021-11-1 6:00"),
          origin_buffer:      0,
          destination_buffer: 0,
          resources:          [{resource_id: "sw_3", in_home: false}]
        }
      ]

      witness_slots = [
        {
          fp_id:              "wit_1",
          start_time:         Time.zone.parse("2021-11-1 2:00"),
          end_time:           Time.zone.parse("2021-11-1 2:30"),
          origin_buffer:      0,
          destination_buffer: 0,
          resources:          [{resource_id: "wit_1", offset: 15, in_home: false}]
        }
      ]

      result = instance.merge_slots(fp_slots, sw_slots)
      # result.sort_by!(:start_time)

      expect(result.length).to eq 4

      expect(result[0][:start_time]).to eq(Time.zone.parse("2021-11-1 2:00"))
      expect(result[0][:end_time]).to eq(Time.zone.parse("2021-11-1 3:00"))
      expect(result[0][:origin_buffer]).to eq 0
      expect(result[0][:destination_buffer]).to eq(-120)
      expect(result[0][:resources]).to eq [{resource_id: "fp_1", in_home: true},
                                           {resource_id: "sw_1", in_home: false}]

      expect(result[1][:start_time]).to eq(Time.zone.parse("2021-11-1 3:00"))
      expect(result[1][:end_time]).to eq(Time.zone.parse("2021-11-1 4:00"))
      expect(result[1][:origin_buffer]).to eq(-60)
      expect(result[1][:destination_buffer]).to eq(-60)
      expect(result[1][:resources]).to eq [{resource_id: "fp_1", in_home: true},
                                           {resource_id: "sw_2", in_home: false}]

      expect(result[2][:start_time]).to eq(Time.zone.parse("2021-11-1 4:00"))
      expect(result[2][:end_time]).to eq(Time.zone.parse("2021-11-1 5:00"))
      expect(result[2][:origin_buffer]).to eq(-120)
      expect(result[2][:destination_buffer]).to eq 0
      expect(result[2][:resources]).to eq [{resource_id: "fp_1", in_home: true},
                                           {resource_id: "sw_3", in_home: false}]

      expect(result[3][:start_time]).to eq(Time.zone.parse("2021-11-1 5:00"))
      expect(result[3][:end_time]).to eq(Time.zone.parse("2021-11-1 6:00"))
      expect(result[3][:origin_buffer]).to eq 5
      expect(result[3][:destination_buffer]).to eq 5
      expect(result[3][:resources]).to eq [{resource_id: "fp_2", in_home: true},
                                           {resource_id: "sw_3", in_home: false}]

      result = instance.merge_slots(result, witness_slots)

      expect(result.length).to eq 1

      expect(result[0][:start_time]).to eq(Time.zone.parse("2021-11-1 2:00"))
      expect(result[0][:end_time]).to eq(Time.zone.parse("2021-11-1 2:30"))
      expect(result[0][:origin_buffer]).to eq 0
      expect(result[0][:destination_buffer]).to eq(-150)
      expect(result[0][:resources]).to eq [{resource_id: "fp_1", in_home: true},
                                           {resource_id: "sw_1", in_home: false},
                                           {resource_id: "wit_1", offset: 15, in_home: false}]
    end

    it "rounds time to 15 minutes" do
      expect(instance.round_time_15(Time.zone.parse("2021-11-1 09:31"))).to eq(Time.zone.parse("2021-11-1 09:30"))
      expect(instance.round_time_15(Time.zone.parse("2021-11-1 09:43"))).to eq(Time.zone.parse("2021-11-1 09:45"))
      expect(instance.round_time_15(Time.zone.parse("2021-11-1 09:53"))).to eq(Time.zone.parse("2021-11-1 10:00"))
      expect(instance.round_time_15(Time.zone.parse("2021-11-1 09:07"))).to eq(Time.zone.parse("2021-11-1 09:00"))
      expect(instance.round_time_15(Time.zone.parse("2021-11-1 09:08"))).to eq(Time.zone.parse("2021-11-1 09:15"))
    end

    it "validates slots that are long enough" do
      # 2 hour slot, 1 hr visit, 30 min driving total, no buffer
      expect(instance.is_valid(slot)).to be true

      slot[:origin_buffer] = 15
      # 2 hour slot, 1 hr visit, 30 min driving total, one 15 min buffer
      expect(instance.is_valid(slot)).to be true
    end

    it "blocks slots that are too short" do
      slot[:origin_buffer] = 15
      slot[:destination_buffer] = 15

      # 2 hour slot, 1 hr visit, 30 min driving total, two 15 minute buffers
      expect(instance.is_valid(slot)).to be false
    end

    it "adds visit time to short slot" do
      slot[:end_time] = Time.zone.parse("2021-11-1 2:30")
      result = instance.find_visit_times_in_slot(slot)

      expect(result.length).to eq(1)

      expect(result[0][:appt_start]).to eq(Time.zone.parse("2021-11-1 1:15"))
      expect(result[0][:appt_end]).to eq(Time.zone.parse("2021-11-1 2:15"))
      expect(result[0][:expected_drive]).to eq(15)
    end

    it "adds visit time to long slot" do
      slot[:end_time] = Time.zone.parse("2021-11-1 8:00")
      result = instance.find_visit_times_in_slot(slot)

      expect(result.length).to eq(3)

      expect(result[0][:appt_start]).to eq(Time.zone.parse("2021-11-1 1:15"))
      expect(result[0][:appt_end]).to eq(Time.zone.parse("2021-11-1 2:15"))
      expect(result[0][:expected_drive]).to eq(15)
      expect(result[0][:contiguous]).to eq(true)

      expect(result[1][:appt_start]).to eq(Time.zone.parse("2021-11-1 6:40"))
      expect(result[1][:appt_end]).to eq(Time.zone.parse("2021-11-1 7:40"))
      expect(result[1][:expected_drive]).to eq(20)
      expect(result[1][:contiguous]).to eq(true)

      expect(result[2][:appt_start]).to eq(Time.zone.parse("2021-11-1 3:15"))
      expect(result[2][:appt_end]).to eq(Time.zone.parse("2021-11-1 4:15"))
      expect(result[2][:expected_drive]).to eq(17)
      expect(result[2][:contiguous]).to eq(false)
    end

    it "checks for overlap" do
      # different fp_id
      range2 = {
        fp_id:      "different",
        start_time: Time.zone.parse("2021-11-1 1:00"),
        end_time:   Time.zone.parse("2021-11-1 3:00")
      }
      expect(instance.is_blocking(slot, range2)).to be false

      # same fp_id
      range2[:fp_id] = "5"
      expect(instance.is_blocking(slot, range2)).to be true

      # partial end
      range2[:start_time] = Time.zone.parse("2021-11-1 1:00")
      range2[:end_time] = Time.zone.parse("2021-11-1 3:30")
      expect(instance.is_blocking(slot, range2)).to be true

      # partial beginning
      range2[:start_time] = Time.zone.parse("2021-11-1 0:30")
      range2[:end_time] = Time.zone.parse("2021-11-1 1:30")
      expect(instance.is_blocking(slot, range2)).to be true

      # not overlaping
      range2[:start_time] = Time.zone.parse("2021-11-1 5:00")
      range2[:end_time] = Time.zone.parse("2021-11-1 6:00")
      expect(instance.is_blocking(slot, range2)).to be false
    end

    it "filters similar slots" do
      # Filter options that have the same time and field provider
      option1 = {cx_start: Time.zone.parse("2021-11-1 1:00"), fp_id: 5}
      option2 = {cx_start: Time.zone.parse("2021-11-1 1:00"), fp_id: 6}
      option3 = {cx_start: Time.zone.parse("2021-11-1 2:00"), fp_id: 7}
      option4 = {cx_start: Time.zone.parse("2021-11-1 1:00"), fp_id: 5}
      expect(instance.filter_similarity([option1, option2, option3, option4])).to eq([option1, option2, option3])
    end

    it "finds overlap" do
      time1 = Time.zone.now
      time2 = time1 + 1.hour
      time3 = time1 + 2.hours
      time4 = time1 + 3.hours

      adjacent = instance.find_overlap(time1, time2, time3, time4)
      enclosed = instance.find_overlap(time1, time4, time2, time3)
      covering = instance.find_overlap(time2, time3, time1, time4)
      begining = instance.find_overlap(time1, time3, time2, time4)
      overhang = instance.find_overlap(time2, time4, time1, time3)

      expect(adjacent).to eq(nil)
      expect(enclosed).to eq([time2, time3])
      expect(covering).to eq([time2, time3])
      expect(begining).to eq([time2, time3])
      expect(enclosed).to eq([time2, time3])
    end

    it "checks slot duration" do
      slot = {
        start_time:         Time.zone.parse("2021-11-1 1:00"),
        end_time:           Time.zone.parse("2021-11-1 2:00"),
        grace_period:       0,
        origin_buffer:      0,
        destination_buffer: 0
      }

      # No modifiers
      expect(instance.slot_length_exceeds_duration(slot)).to be true

      slot[:origin_buffer] = 15
      # Can't fit with buffer
      expect(instance.slot_length_exceeds_duration(slot)).to be false

      options[:max_grace_period] = 15
      instance = service.new([], [], parameters, options)
      # can fit with grace period
      expect(instance.slot_length_exceeds_duration(slot)).to be true

      slot[:start_time] = Time.zone.parse("2021-11-1 1:30")
      slot[:origin_buffer] = -1000
      # negative buffer only affects drive time, visit still needs to fit
      expect(instance.slot_length_exceeds_duration(slot)).to be false
    end

    context "with multiple options" do
      let(:short_list) { [3, 2, 1].map {|s| {scores: {total_score: s}} } }
      let(:medium_list) { [6, 5, 4, 3, 2, 1].map {|s| {scores: {total_score: s}} } }
      let(:long_list) { [10, 9, 8, 7, 6, 5, 4, 3, 2, 1].map {|s| {scores: {total_score: s}} } }
      let(:override_list) { [99, 99, 99, 99, 99, 90, 89, 60, 59].map {|s| {scores: {total_score: s}} } }

      let(:rank_thresholds) do
        {
          high_rank_percentile_threshold:   90,
          medium_rank_percentile_threshold: 60,
          high_rank_absolute_threshold:     90,
          medium_rank_absolute_threshold:   60
        }
      end

      it "categorizes them" do
        short_expected = %i[high low low]
        medium_expected = %i[high medium medium low low low]
        long_expected = %i[high medium medium medium low low low low low low]
        override_expected = %i[high high high high high high medium medium low]

        short_result = instance.add_rank_categories(short_list, rank_thresholds)
        medium_result = instance.add_rank_categories(medium_list, rank_thresholds)
        long_result = instance.add_rank_categories(long_list, rank_thresholds)
        override_result = instance.add_rank_categories(override_list, rank_thresholds)

        expect(short_result.pluck(:rank_category)).to eq(short_expected)
        expect(medium_result.pluck(:rank_category)).to eq(medium_expected)
        expect(long_result.pluck(:rank_category)).to eq(long_expected)
        expect(override_result.pluck(:rank_category)).to eq(override_expected)
      end
    end
  end
end
