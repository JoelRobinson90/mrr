# typed: true
# frozen_string_literal: true

class PapertrailController < ApplicationController
  before_action :authenticate_medarrive_super_admin!

  def show_history
    @object = params[:type].classify.constantize.find(params[:id])
    @story = []
    PaperTrailScrapbook::LifeHistory.new(@object).story.each do |(title,changes)|
      # Child objects will have the postgres id in brackets after the name
      is_association = title =~ /\[[0-9]+\]/
      @story << {title: title, changes: changes.compact.map {|change| change.split(":", 2)}, is_association: is_association}
    end

    @story.reverse!
  end

  def authenticate_medarrive_super_admin!
    user_not_authorized! unless current_user&.is_super_admin?
  end
end