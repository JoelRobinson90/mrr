# typed: true
# frozen_string_literal: true

module PushToExternal
  extend ActiveSupport::Concern

  included do
    attr_accessor :skip_push_to_external
    attr_accessor :skip_push_to_alayacare
    attr_accessor :skip_push_to_athena

    before_save :push_to_external

    after_commit :push_to_external_after_commit

    def push_enabled?
      # Until we can get our test environment pointed away from UAT, don't try to connect to
      # AC from specs
      return false unless EnvHelper.env_or_nil("ENABLE_PUSH_TO_EXTERNAL")
      return false if skip_push_to_external

      true
    end

    def push_to_external
      return unless push_enabled?

      vaildation_check(:push_to_athena_validation)

      # Only abort if the first external system fails
      create_or_update_with_retry(:push_to_wheniwork, abort_on_fail = true)
      create_or_update_with_retry(:push_to_alayacare) unless skip_push_to_alayacare

      # continue save
      true
    end

    def push_to_external_after_commit
      return unless push_enabled?

      create_or_update_with_retry(:push_to_athena) unless skip_push_to_athena
      true
    end

    def create_or_update_with_retry(push_method, abort_on_fail = false)
      mode = persisted? ? :update : :create

      if respond_to? push_method
        result = send(push_method, mode)

        # if we failed to update due to missing object, create instead.
        result = send(push_method, :create) if result&.code == 404 && mode == :update

        err_column = "#{push_method}_error"

        # Since we are now syncing to multiple systems, we don't want to prevent
        # save if a later subsystem fails.  We still want to notify user so they can
        # try again (since updates can fall back to creates).
        unless result.success?
          err = result.error.presence || "#{result.code} - #{result.body}"
          msg = "#{push_method} failed: #{err}"
          errors.add(:base, msg)
          Sentry.capture_message(msg)
          id_str = [self[:ma_id], self[:external_id]].compact.join(', ')
          Rails.logger.error("#{msg} (#{id_str})")
          err_column = "#{push_method}_error"

          if respond_to? err_column
            # save error to model for fast debugging
            if self.persisted?
              self.paper_trail.update_column(err_column.to_s, msg)
            else
              self[err_column] = msg
            end
          end

          throw :abort if abort_on_fail
        end

        if result.success? && self[err_column].present?
          # clear error on successful push
          self.paper_trail.update_column(err_column.to_s, nil)
        end

        result
      end
    end

    def vaildation_check(push_method)
      if respond_to? push_method
        result = send(push_method)

        unless result.success?
          err = result.error.presence || "#{result.code} - #{result.body}"
          errors.add(:base, err)
          throw :abort
        end
      end

      true
    end
  end
end
