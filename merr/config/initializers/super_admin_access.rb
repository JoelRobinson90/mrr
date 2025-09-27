# frozen_string_literal: true

class CanAccessSuperAdminRoutes
  def self.matches?(request)
    current_user = request.env["warden"].user
    current_user.present? && current_user.respond_to?(:is_super_admin?) && current_user.is_super_admin?
  end
end
