module SessionFilters
  extend ActiveSupport::Concern

  included do
    before_action :get_and_save_filters!
    
    def reset_filters!
      session[:filters].delete(filter_session_key)
    end

    def reset_all_filters!
      session.delete(:filters)
    end

    def filters
      []
    end

    private

    def get_and_save_filters!
      session[:filters] ||= {}

      reset_filters! if params[:reset_filters]

      # Get filters from params
      param_filters = params.permit(*filters).to_h.transform_values(&:presence).symbolize_keys

      # split most filters by pipe to allow multi-select
      filters.excluding(:start, :end, :timezone).each do |key|
        param_filters[key] = param_filters[key].split("|") if param_filters[key]
      end

      unless enable_session_filters?
        return @filters = param_filters
      end

      # Get existing session filters
      session_filters = session[:filters][filter_session_key]&.symbolize_keys || {}

      # Override any session filters with ones in params
      @filters = session_filters.merge(param_filters)

      # Save result back to session for next time
      session[:filters][filter_session_key] = @filters
    end

    def filter_session_key
      "#{controller_path}##{action_name}"
    end

    def enable_session_filters?
      false
    end
  end
end
