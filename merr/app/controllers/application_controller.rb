# typed: true
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionFilters
  include TempAuthToken

  before_action :set_paper_trail_whodunnit
  # after_action :store_location

  rescue_from CanCan::AccessDenied do |exception|
    Sentry.capture_exception(exception)
    user_not_authorized!
  end

  # TODO: [erik] fix this before session filters is turned back on
  # Warden::Manager.before_logout do
  #   reset_all_filters!
  # end

  def profile(title)
    t = Time.zone.now
    result = yield

    run_id = @run_id.present? ? " (run_id: #{@run_id})" : ""
    p "#{format('%.3f', Time.zone.now - t)} seconds to #{title}#{run_id}"

    result
  end

  def health_check
    # Adding this line causes a connection check for the DB
    # if the Connection to the db fails, this page will not respond with a 200
    # thus preventing the ALB from routing traffic to this server
    @current_datatbase_version = ActiveRecord::Migrator.current_version
    render_component "HealthCheckPage"
  end

  def redirect_to_home_page
    if session[:return_to]
      redirect_to session.delete(:return_to)
    elsif user_home_page_path
      redirect_to user_home_page_path
    else
      raise "This user has no where to go"
    end
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def pagination_props(paginated_collection)
    {
      current_page:  paginated_collection.current_page,
      total_pages:   paginated_collection.total_pages,
      rows_per_page: paginated_collection.per_page
    }
  end

  def append_breadcrumb(text)
    # Truncate old breadcrumbs if current page is already in history
    stored_breadcrumbs.each_with_index do |breadcrumb, i|
      if breadcrumb["href"] == request.path
        session[:breadcrumbs] = session[:breadcrumbs][0...i]
        break
      end
    end

    # Add current page
    session[:breadcrumbs] = stored_breadcrumbs << {text: text, href: request.path}
  end

  def stored_breadcrumbs
    session[:breadcrumbs] || []
  end

  private

  def authenticate_field_scheduler_user!
    user_not_authorized! unless current_user&.is_field_scheduler?
  end

  # TODO: Fix this or find another solution to properly redirect users when
  # signing back in after a session timeout.
  # Any user_return_to path is also used to redirect from the root path (no timeout needed)
  # def store_location
  #   # store last url - this is needed for post-login redirect to whatever the user last visited.
  #   if (request.fullpath != "/users/sign_in" &&
  #       request.fullpath != "/users/sign_up" &&
  #       request.fullpath != "/users/password" &&
  #       request.fullpath != "/users/sign_out" &&
  #       !request.xhr?) # don't store ajax calls
  #     session["user_return_to"] = request.fullpath
  #   end
  # end

  def user_home_page_path
    if !current_user
      new_user_session_path
    elsif current_user.is_medarrive_customer_support?
      admin_root_path
    elsif current_user.is_medarrive_account?
      admin_root_path
    elsif current_user.is_field_provider?
      field_root_path
    elsif current_user.is_external_account?
      field_root_path
    elsif current_user.is_demand_coordinator?
      if current_user.account.demand_partner&.is_bright?
        partner_path
      end
    end
  end

  def render_component(component, props = {})
    @react_view = true
    render react_component: component, props: props_with_layout(props)
  end

  def render_partial_component(component, props = {})
    render json: {
      componentName:  component,
      componentProps: props
    }
  end

  def props_with_layout(props = {})
    props.merge(layout_props: layout_props)
  end
  helper_method :props_with_layout

  # For common props that are used in layouts
  # Override this in your controller
  def layout_props
    {
      environment:  EnvHelper.env_or_nil("HOST_ENV") || Rails.env,
      rails_action: "#{controller_name}##{action_name}",
      current_user: current_user&.as_json(
        only:    %i[id account_type],
        include: [
          account: {
            only:    [:display_name],
            methods: [:display_name]
          }
        ]
      ),
      hide_layout:  !!@hide_layout_components
    }
  end
  helper_method :layout_props

  def current_account
    current_user&.account
  end

  def user_not_authorized!
    if current_user
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referer || root_path)
    else
      session[:return_to] ||= request.fullpath unless request.fullpath.include? "polling"
      flash[:alert] = "You must be logged in to perform this action."
      redirect_to(new_user_session_path)
    end
  end

  def requested_redirect_path
    params[:request_redirect]
  end
end
