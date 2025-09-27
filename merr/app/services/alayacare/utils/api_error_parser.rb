# frozen_string_literal: true

module Alayacare
  module Utils
    class ApiErrorParser
      def initialize(body)
        @body = body
        @errors = @body
        # for some odd reason sometimes the body returned with errors from Alacayare is returned as a string.
        if @body.is_a? String
          @errors = begin
            JSON.parse(@body)
          rescue StandardError
            nil
          end
        end

        @errors = @errors.symbolize_keys if @errors.respond_to? :symbolize_keys
      end

      def parsed_errors
        validation_errors = []

        # handle validation errors from alayacare
        if @errors&.key?(:message) && @errors[:message].include?("Validation error")
          @errors.except!(:code, :message)
          validation_errors = @errors.map {|field, values| "#{field}: #{values.join(',')}" }
        end

        if validation_errors.length.positive?
          validation_errors.join(", ")
        elsif @errors && @errors[:message]
          @errors[:message]
        else
          "Something went wrong: #{@errors}"
        end
      end
    end
  end
end
