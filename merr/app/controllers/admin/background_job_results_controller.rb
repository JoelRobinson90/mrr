# typed: true
# frozen_string_literal: true

module Admin
  class BackgroundJobResultsController < BaseController
    def index
      @results = BackgroundJobResult.order(created_at: :desc)
                                    .paginate(page: @current_page, per_page: @per_page)

      render_component "BackgroundJobResultsIndexPage", {
        background_job_results: @results.collect do |background_job_result|
                                  background_job_result.to_builder.attributes!
                                end,
        queue_size:             Delayed::Job.where(failed_at: nil).count,
        queue_errors:           Delayed::Job.where.not(failed_at: nil).count,
        pagination:             pagination_props(@results)
      }
    end
  end
end
