# typed: true
# frozen_string_literal: true

module Admin
  class TagsController < BaseController
    load_and_authorize_resource
    rescue_from ActiveRecord::RecordNotUnique, with: :duplicate_error_handler

    def index
      @group = params[:group] || "Appointment"

      @tags = @tags.where(group: @group)
                   .paginate(page: @current_page, per_page: @per_page)
                   .order(created_at: :desc)

      render_component "TagIndexPage", {
        tags:       @tags.as_json,
        pagination: pagination_props(@tags),
        group:      @group
      }
    end

    def show
      append_breadcrumb(@tag.name)
      render_component "TagShowPage",
                       tag: @tag.as_json(only: %i[id name color description group taggings_count])
    end

    def new
      @tag = Tag.new

      render_component "TagEditPage", tag: @tag.as_json
    end

    def edit
      render_component "TagEditPage", tag: @tag.as_json
    end

    def create
      @tag = Tag.new(tag_params)

      if @tag.save
        redirect_to admin_tag_path(@tag), notice: "Tag created"
      else
        flash[:alert] = @tag.errors.full_messages
        redirect_to admin_tags_path
      end
    end

    def update
      if @tag.update(tag_params)
        redirect_to admin_tag_path(@tag), notice: "Tag updated"
      else
        flash[:alert] = [@tag.errors.full_messages].flatten
        redirect_to admin_tag_path(@tag)
      end
    end

    def destroy
      @group = @tag.group || "Appointment"

      if @tag.destroy
        flash[:notice] = "tag was deleted successfully."
      else
        flash[:alert] = @tag.errors.full_messages
      end

      redirect_to admin_tags_path(group: @group)
    end

    private

    def duplicate_error_handler
      flash[:alert] = "Tag with name: '#{@tag.name }' has been archived. Please chose a different name."
      redirect_to admin_tags_path(group: @group)
    end

    # Only allow a list of trusted parameters through.
    def tag_params
      params.require(:tag).permit(:id, :name, :color, :description, :group)
    end
  end
end
