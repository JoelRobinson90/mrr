# frozen_string_literal: true

module Types
  class VisitRequestStatusType < BaseEnum
    VisitRequest::STATUSES.each do |status|
      value status.to_s, value: status
    end
  end
end
