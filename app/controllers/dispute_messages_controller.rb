class DisputeMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dispute
  before_action :check_dispute_access

  def create
    @message = @dispute.dispute_messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.html { redirect_to @dispute, notice: "Message envoyé avec succès." }
        format.turbo_stream
        format.json { render json: @message, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Erreur lors de l'envoi du message." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message-form", partial: "disputes/message_form", locals: { dispute: @dispute, message: @message }) }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @message = @dispute.dispute_messages.find(params[:id])
    
    if @message.user == current_user && @message.can_be_edited_by?(current_user)
      @message.destroy
      respond_to do |format|
        format.html { redirect_to @dispute, notice: "Message supprimé." }
        format.turbo_stream
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to @dispute, alert: "Vous ne pouvez pas supprimer ce message." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  private

  def set_dispute
    @dispute = Dispute.find(params[:dispute_id])
  end

  def check_dispute_access
    unless @dispute.can_be_viewed_by?(current_user)
      redirect_to disputes_path, alert: "Vous n'avez pas accès à ce litige."
    end
  end

  def message_params
    params.require(:dispute_message).permit(:message, :visibility, attachments: [])
  end
end
