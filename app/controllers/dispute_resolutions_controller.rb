class DisputeResolutionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dispute
  before_action :check_dispute_access
  before_action :set_resolution, only: [:show, :update, :destroy, :accept, :reject, :implement]

  def create
    @resolution = @dispute.dispute_resolutions.build(resolution_params)
    @resolution.proposed_by = current_user

    if @resolution.save
      respond_to do |format|
        format.html { redirect_to @dispute, notice: "Proposition de résolution soumise avec succès." }
        format.turbo_stream
        format.json { render json: @resolution, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Erreur lors de la soumission de la proposition." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("resolution-form", partial: "disputes/resolution_form", locals: { dispute: @dispute, resolution: @resolution }) }
        format.json { render json: @resolution.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @resolution }
    end
  end

  def update
    if @resolution.proposed_by == current_user && @resolution.pending?
      if @resolution.update(resolution_params)
        respond_to do |format|
          format.html { redirect_to @dispute, notice: "Proposition mise à jour avec succès." }
          format.turbo_stream
          format.json { render json: @resolution }
        end
      else
        respond_to do |format|
          format.html { redirect_to @dispute, alert: "Erreur lors de la mise à jour." }
          format.json { render json: @resolution.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Vous ne pouvez pas modifier cette proposition." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  def destroy
    if @resolution.proposed_by == current_user && @resolution.pending?
      @resolution.destroy
      respond_to do |format|
        format.html { redirect_to @dispute, notice: "Proposition supprimée." }
        format.turbo_stream
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Vous ne pouvez pas supprimer cette proposition." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  def accept
    if @resolution.can_be_accepted_by?(current_user)
      @resolution.accept_by!(current_user)
      respond_to do |format|
        format.html { redirect_to @dispute, notice: "Proposition acceptée." }
        format.turbo_stream
        format.json { render json: @resolution }
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Vous ne pouvez pas accepter cette proposition." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  def reject
    if @resolution.can_be_rejected_by?(current_user)
      reason = params[:rejection_reason]
      @resolution.reject_by!(current_user, reason)
      respond_to do |format|
        format.html { redirect_to @dispute, notice: "Proposition rejetée." }
        format.turbo_stream
        format.json { render json: @resolution }
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Vous ne pouvez pas rejeter cette proposition." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  def implement
    if current_user.can_mediate_disputes? && @resolution.accepted?
      notes = params[:implementation_notes]
      @resolution.implement!(notes)
      respond_to do |format|
        format.html { redirect_to @dispute, notice: "Résolution implémentée avec succès." }
        format.turbo_stream
        format.json { render json: @resolution }
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Vous n'avez pas l'autorisation d'implémenter cette résolution." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  private

  def set_dispute
    @dispute = Dispute.find(params[:dispute_id])
  end

  def set_resolution
    @resolution = @dispute.dispute_resolutions.find(params[:id])
  end

  def check_dispute_access
    unless @dispute.can_be_viewed_by?(current_user)
      redirect_to disputes_path, alert: "Vous n'avez pas accès à ce litige."
    end
  end

  def resolution_params
    params.require(:dispute_resolution).permit(:resolution_type, :details, :amount, :expires_at)
  end
end
