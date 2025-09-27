# typed: true
# frozen_string_literal: true

module ApplicationHelper
  def current_user_dashboard_path
    if current_user.is_medarrive_admin?
      admin_root_path
    elsif current_user.is_field_admin?
      dashboard_field_admin_root_path
    end
  end
end