module Types
  class SchedulerVisitType < Types::BaseObject
    field :id, String, null: true
    field :fp_id, String, null: false
    field :fp_name, String, null: false
    field :start_time, String, null: false
    field :end_time, String, null: false
    field :cx_start, String, null: false
    field :cx_end, String, null: false
    field :expected_drive, Integer, null: true
    field :run_id, String, null: false
    field :total_score, Integer, null: true
    field :drive_score, Integer, null: true
    field :proximity_score, Integer, null: true
    field :utilization_score, Integer, null: true
    field :shift_shortening_penalty_score, Integer, null: true
    field :rank_category, String, null: true
    field :grace_period, Integer, null: true
    field :arrival_window_start, String, null: true
    field :arrival_window_end, String, null: true
    field :destination, String, null: true
    field :destination_drive_time, Integer, null: true
    field :origin, String, null: true
    field :origin_drive_time, Integer, null: true
    field :selected, Boolean, null: true
    field :rank, Integer, null: true
    field :resources, [Types::VisitResourceType], null: false
  end
end
