# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def can?(*args)
      current_ability.can?(*args)
    end

    def unauthorized_error
      "You are not authorized to perform this action."
    end

    def authorize!(*args)
      current_ability.authorize!(*args)
    end

    def current_user
      context[:current_user]
    end

    def current_ability
      context[:current_ability]
    end

    def log_message(msg, level: :info)
      msg = "#{@run_id} #{msg}"
      level == :info ? Rails.logger.info(msg) : Rails.logger.error(msg)
      # To actually show up in data dog "Rails.logger.info" doesn't work.
      p msg
    end
  end
end
