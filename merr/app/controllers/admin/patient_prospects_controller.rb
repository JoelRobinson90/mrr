# typed: true
# frozen_string_literal: true

module Admin
  class PatientProspectsController < BaseController
    load_and_authorize_resource

    def index
      @patient_prospects = @patient_prospects
                           .includes(:demand_partner)
                           .paginate(page: @current_page, per_page: @per_page)
                           .order(created_at: :desc)

      @patient_prospects = @patient_prospects.search(params[:s]) if params[:s].present?

      render_component "PatientProspectIndexPage", {
        patient_prospects: @patient_prospects.map(&:to_builder).map(&:attributes!),
        pagination:        pagination_props(@patient_prospects),
        query:             params[:s]
      }
    end

    def destroy
      if @patient_prospect.destroy
        flash[:notice] = "Prospective patient was deleted successfully."
      else
        flash[:alert] = @patient_prospect.errors.full_messages
      end

      redirect_to admin_patient_prospects_path
    end
  end
end
