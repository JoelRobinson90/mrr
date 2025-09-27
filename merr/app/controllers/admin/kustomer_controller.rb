# typed: true
# frozen_string_literal: true

module Admin
  class KustomerController < BaseController
    load_resource

    def new_patients
      @patients = Patient.where(region: nil)
                         .accessible_by(current_ability).includes(:address, :demand_partner, :taggings)
      @demand_partners = DemandPartner.accessible_by(current_ability).select(:id, :name)

      params[:demand_partner_id] = params[:demand_partner_id] || DemandPartner.first.id

      @patients = @patients.where(demand_partner_id: params[:demand_partner_id])

      @geojson_patients = GeoJsonBuilder.call(@patients)

      render_component "KustomerMapSelectionNewPage",
                       patients:          @patients.as_json(methods: %w[display_phone_number],
                                                            include: {
                                                              address:        {only: %i[address_line_one city state]},
                                                              demand_partner: {only: [:name]}
                                                            }),
                       geojson:           @geojson_patients,
                       demand_partners:   @demand_partners,
                       demand_partner_id: params[:demand_partner_id].to_i
    end

    def create_patients
      authorize! :write, Patient

      pending_job = BackgroundJobResult.create(
        label:    params[:title],
        status:   "pending",
        job_type: "region_creation"
      )

      create_region = Kustomer::CreateRegion.new(params[:patient_ids], params[:title], pending_job.id)

      create_region.delay.call

      redirect_to admin_background_job_results_path, notice: "Scheduled region creation: '#{params[:title]}'"
    end
  end
end
