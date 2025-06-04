class TicketMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_support_ticket
  before_action :check_ticket_access

  def create
    @message = @support_ticket.ticket_messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.html { redirect_to @support_ticket, notice: "Message envoyé avec succès." }
        format.turbo_stream
        format.json { render json: @message, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to @support_ticket, alert: "Erreur lors de l'envoi du message." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message-form", partial: "support_tickets/message_form", locals: { support_ticket: @support_ticket, message: @message }) }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @message = @support_ticket.ticket_messages.find(params[:id])
    
    if @message.user == current_user && @message.can_be_edited_by?(current_user)
      @message.destroy
      respond_to do |format|
        format.html { redirect_to @support_ticket, notice: "Message supprimé." }
        format.turbo_stream
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to @support_ticket, alert: "Vous ne pouvez pas supprimer ce message." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end

  private

  def set_support_ticket
    @support_ticket = SupportTicket.find(params[:support_ticket_id])
  end

  def check_ticket_access
    unless @support_ticket.can_be_viewed_by?(current_user)
      redirect_to support_tickets_path, alert: "Vous n'avez pas accès à ce ticket."
    end
  end

  def message_params
    params.require(:ticket_message).permit(:message, :internal, attachments: [])
  end
end
