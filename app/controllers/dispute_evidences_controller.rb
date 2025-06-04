class DisputeEvidencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dispute
  before_action :check_dispute_access
  before_action :set_evidence, only: [:show, :destroy, :approve, :reject]

  def create
    @evidence = @dispute.dispute_evidences.build(evidence_params)
    @evidence.user = current_user

    if @evidence.save
      respond_to do |format|
        format.html { redirect_to @dispute, notice: "Preuve soumise avec succès." }
        format.turbo_stream
        format.json { render json: @evidence, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Erreur lors de la soumission de la preuve." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("evidence-form", partial: "disputes/evidence_form", locals: { dispute: @dispute, evidence: @evidence }) }
        format.json { render json: @evidence.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    unless @evidence.can_be_viewed_by?(current_user)
      redirect_to @dispute, alert: "Vous n'avez pas accès à cette preuve."
      return
    end

    respond_to do |format|
      format.html
      format.json { render json: @evidence.as_json(include: :files) }
    end
  end

  def destroy
    if @evidence.user == current_user && @evidence.pending_review?
      @evidence.destroy
      respond_to do |format|
        format.html { redirect_to @dispute, notice: "Preuve supprimée." }
        format.turbo_stream
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Vous ne pouvez pas supprimer cette preuve." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  def approve
    if current_user.can_mediate_disputes? && @evidence.can_be_reviewed_by?(current_user)
      @evidence.approve!(current_user, params[:review_notes])
      respond_to do |format|
        format.html { redirect_to @dispute, notice: "Preuve approuvée." }
        format.turbo_stream
        format.json { render json: @evidence }
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Vous n'avez pas l'autorisation d'approuver cette preuve." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  def reject
    if current_user.can_mediate_disputes? && @evidence.can_be_reviewed_by?(current_user)
      review_notes = params[:review_notes]
      if review_notes.present?
        @evidence.reject!(current_user, review_notes)
        respond_to do |format|
          format.html { redirect_to @dispute, notice: "Preuve rejetée." }
          format.turbo_stream
          format.json { render json: @evidence }
        end
      else
        respond_to do |format|
          format.html { redirect_to @dispute, alert: "Une raison de rejet est requise." }
          format.json { render json: { error: "Review notes required" }, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Vous n'avez pas l'autorisation de rejeter cette preuve." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  private

  def set_dispute
    @dispute = Dispute.find(params[:dispute_id])
  end

  def set_evidence
    @evidence = @dispute.dispute_evidences.find(params[:id])
  end

  def check_dispute_access
    unless @dispute.can_be_viewed_by?(current_user)
      redirect_to disputes_path, alert: "Vous n'avez pas accès à ce litige."
    end
  end

  def evidence_params
    params.require(:dispute_evidence).permit(:title, :description, :evidence_type, files: [])
  end
end
