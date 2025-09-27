# typed: true
# frozen_string_literal: true

module Alayacare
  class CreateExternalVisitNote < ApiClient
    def initialize(alayacare_id, text, user=nil)
      super()

      @alayacare_id = alayacare_id
      @text = text
      @user = user
    end

    def call
      @api.post("scheduler/visits/#{@alayacare_id}/notes", body)
    end

    def body
      sig = ""
      if @user.present?
        if @user.account.present?
          sig = " -#{@user.account&.first_name} #{@user.account&.last_name}"
        else
          sig = " -#{@user.email}"
        end
      end

      return {text: @text + sig}
    end
  end
end
