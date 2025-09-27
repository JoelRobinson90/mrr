# frozen_string_literal: true

# typed: true
class AdminNotesController < ApplicationController
  load_and_authorize_resource

  # GET /admin_notes
  def index; end

  # GET /admin_notes/1
  def show; end

  # GET /admin_notes/new
  def new; end

  # GET /admin_notes/1/edit
  def edit; end

  # POST /admin_notes
  def create
    if @admin_note.save
      redirect_to @admin_note, notice: "Admin note was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /admin_notes/1
  def update
    if @admin_note.update(admin_note_params)
      redirect_to @admin_note, notice: "Admin note was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /admin_notes/1
  def destroy
    @admin_note.destroy
    redirect_to request.referer, notice: "Admin note was successfully destroyed."
  end

  private

  # Only allow a list of trusted parameters through.
  def admin_note_params
    params.require(:admin_note).permit(:content, :creator_id, :notable_id, :notable_type)
  end
end
