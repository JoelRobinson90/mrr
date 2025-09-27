
class Api::V1::VisitsController < ApiController

  def show
    visit = Visit.where(id: params[:visit_id])
    if visit
      render json: {visit: visit[0].to_builder.attributes!}, status: :ok
    else
      render body: nil, status: :no_content
    end
  end

  def index
    # @TODO: not sure what's gonna to happen if current_user.account is no FieldProvider
    visits = Visit.where(field_provider: current_user.account).order(start_time: :desc).limit(5)
    render json: { visits: visits.map{|v| v.to_builder.attributes! }, current_user: current_user.account }, status: :ok
  end
end
