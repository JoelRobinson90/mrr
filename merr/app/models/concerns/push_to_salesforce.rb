# frozen_string_literal: true

module PushToSalesforce
  extend ActiveSupport::Concern
  include GenerateMaId

  included do
    after_commit :push_to_salesforce_after_commit, if: :should_push_to_salesforce?

    attr_accessor :skip_push_to_salesforce

    def should_push_to_salesforce?
      false
    end

    def push_to_salesforce
      return unless Flipper.enabled?(:push_to_salesforce)
      return if skip_push_to_salesforce

      result = Lambdaforce::PushRecord.call(salesforce_push_body)

      # TODO: How to handle sync error?
      Sentry.capture_message(result.payload.to_json) unless result.success?

      result.success?
    end

    def push_to_salesforce_after_commit
      push_to_salesforce

      # Always return true to save object
      true
    end

    # Meant to be run after commit, so looking at previous attr changes vs. current ones
    def salesforce_push_body(payload_type = nil)
      {
        ma_id:         ma_id,
        message_group: ma_object_message_group,
        mode:          id_previously_changed? ? :create : :update,
        changes:       previous_changes.keys,
        payload_type:  ma_object_payload_type(payload_type),
        payload:       to_ma_object
      }
    end
  end
end
