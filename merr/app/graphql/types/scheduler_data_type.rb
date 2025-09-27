module Types
  class SchedulerDataType < Types::BaseObject
    field :success, Boolean, null: true
    field :suggested_visits, [Types::SchedulerVisitType], null: false
    field :error_message, String, null: true
  end
end
