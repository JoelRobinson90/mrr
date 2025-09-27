# frozen_string_literal: true

module JwtWeb
  class SchedulerController < BaseController
    def new
      render_component "SchedulerIframePage",
                       mode: "new"
    end

    def reschedule
      render_component "SchedulerIframePage",
                       mode: "reschedule"
    end
  end
end
