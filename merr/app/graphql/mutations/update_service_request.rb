# frozen_string_literal: true

module Mutations
  class UpdateServiceRequest < Mutations::BaseMutation
    argument :id, ID, required: false
    argument :ma_id, ID, required: false
    argument :params, Types::Params::UpdateServiceRequestParams, required: true, as: :service_request_params

    field :service_request, Types::ServiceRequestType, null: true
    field :errors, [String], null: false

    def resolve(id: nil, ma_id: nil, service_request_params:)
      service_request = ServiceRequest.find_by_maybe_ma_id(id: id, ma_id: ma_id)
      return {service_request: nil, errors: [unauthorized_error]} unless service_request && can?(:update, service_request)

      if (service_request.update(service_request_params.to_h))
        {service_request: service_request, errors: []}
      else
        {service_request: nil, errors: service_request.errors.full_messages}
      end
    end
  end
end
