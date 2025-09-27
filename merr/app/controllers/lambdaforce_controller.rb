# frozen_string_literal: true

class LambdaforceController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize_api_key!

  def inbound
    @success=false
    @status=500
    @message=nil

    case params[:payload_type]
    when "Patient"
      import_patient
    when "DemandPartner"
      import_demand_partner
    when "Program"
      import_program
    when "Visit"
      import_visit
    else
      @success=false
      @message="Unsupported payload type"
      @status=400
    end

    render json: {success: @success, message: @message}, :status => @status
  end

  def emit
    @success=false
    @status=500
    @message=nil
    resync_object
    render json: {success: @success, message: @message}, :status => @status
  end

  private

  def extract_type_from_ma_id(ma_id)
    parts = ma_id&.split("_")
    parts[1] if parts.present? && parts.length == 3
  end

  def resync_object
    payload_type = extract_type_from_ma_id(params[:ma_id])
    if payload_type.present?
      if payload_type.end_with?("AdminNote")
        @ma_object = AdminNote.find_by(ma_id: params[:ma_id])
      else
        object_class = payload_type.constantize rescue nil
        # Make sure the requested object's class supports the necessary methods for this operation
        if object_class&.respond_to?(:find_by) && object_class&.method_defined?(:push_to_salesforce)
          @ma_object = object_class.find_by(ma_id: params[:ma_id])  
        else
          @success=false 
          @message="Unsupported object type"
          @status=400
          return
        end
      end

      if @ma_object.nil?
        @success=false
        @message="Record not found"
        @status=400
      elsif @ma_object.push_to_salesforce
        @success=true
        @status=200
      else
        @success=false 
        @message="Resync failed"
        @status=500
      end
    else
      @success=false
      @message="Malformed ma_id"
      @status=400
    end
  end

  def import_patient
    patient_attrs = %i[ma_id first_name last_name phone_number date_of_birth
                        contact_email gender medical_record_number]
    address_attrs = %i[address_line_one city state zipcode]
    patient_params = payload_params.require(:payload).permit(*patient_attrs, address_attributes: address_attrs)

    @patient = Patient.find_by(ma_id: patient_params.delete(:ma_id))
    if @patient.present?
      @patient.skip_push_to_salesforce = true
      @patient.update!(patient_params)
      @success=true
      @status=200
    else
      @success=false
      @message="Record not found"
      @status=400
    end
  end

  def import_demand_partner
    dp_params = payload_params.require(:payload).permit(:ma_id, :name, :short_name)
    @demand_partner = DemandPartner.find_or_initialize_by(ma_id: dp_params.delete(:ma_id))
    @demand_partner.update!(dp_params)
    @success=true
    @status=200
  end

  def import_program
    program_params = payload_params.require(:payload).permit(:ma_id, :name, :active, :demand_partner_ma_id)

    @program = Program.find_or_initialize_by(ma_id: program_params.delete(:ma_id))
    @demand_partner = DemandPartner.find_by(ma_id: program_params.delete(:demand_partner_ma_id))
    if @demand_partner.nil?
      @success=false
      @message="Demand partner record not found"
      @status=400
    else
      @program.update!({
                          **program_params,
                          demand_partner:            @demand_partner,
                          v2:                        true,
                          alayacare_service_code_id: ""
                        })
      @success=true
      @status=200
    end
  end

  def import_visit
    visit_params = payload_params.require(:payload).permit(:ma_id, :confirmed)
    @visit = Visit.find_by(ma_id: visit_params.delete(:ma_id))
    if @visit.present?
      @visit.update!(visit_params)
      @success=true
      @status=200
    else
      @success=false
      @message="Record not found"
      @status=400
    end
  end

  def payload_params
    params.permit(:ma_id, :payload_type, payload: {})
  end

  def authorize_api_key!
    render plain: "Unauthorized", status: :unauthorized unless valid_api_key?
  end

  def valid_api_key?
    request.headers["HTTP_X_API_KEY"] == EnvHelper.env_or_nil("LAMBDAFORCE_INBOUND_SECRET")
  end

  # Override Papertrail whodunnit
  def user_for_paper_trail
    "Lambdaforce Inbound API"
  end
end
