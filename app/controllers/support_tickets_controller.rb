class SupportTicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_support_ticket, only: [:show, :edit, :update, :destroy, :close, :reopen, :rate]
  before_action :check_ticket_access, only: [:show, :edit, :update, :destroy]

  def index
    @support_tickets = current_user.support_tickets
                                  .includes(:assigned_to)
                                  .order(created_at: :desc)
                                  .page(params[:page])
    
    # Filter by status if provided
    @support_tickets = @support_tickets.by_status(params[:status]) if params[:status].present?
    
    # Filter by category if provided
    @support_tickets = @support_tickets.by_category(params[:category]) if params[:category].present?
    
    # Filter by priority if provided
    @support_tickets = @support_tickets.by_priority(params[:priority]) if params[:priority].present?
    
    @ticket_counts = {
      open: current_user.support_tickets.open.count,
      closed: current_user.support_tickets.closed.count,
      urgent: current_user.support_tickets.urgent.count
    }
  end

  def show
    @ticket_messages = @support_ticket.ticket_messages
                                     .visible_to_user
                                     .includes(:user, :attachments)
                                     .order(:created_at)
    
    @new_message = @support_ticket.ticket_messages.build
    
    # Mark messages as read
    mark_messages_as_read
  end

  def new
    @support_ticket = current_user.support_tickets.build
    
    # Pre-fill category if provided
    @support_ticket.category = params[:category] if params[:category].present?
    
    # Pre-fill for dispute support if dispute_id provided
    if params[:dispute_id].present?
      @dispute = current_user.disputes.find_by(id: params[:dispute_id])
      @support_ticket.category = 'dispute_support'
      @support_ticket.title = "Support pour le litige #{@dispute&.reference_number}"
    end
  end

  def create
    @support_ticket = current_user.support_tickets.build(support_ticket_params)

    if @support_ticket.save
      # Auto-assign to available agent if urgent
      auto_assign_if_urgent
      
      redirect_to @support_ticket, notice: "Ticket de support créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless @support_ticket.can_be_edited_by?(current_user)
      redirect_to @support_ticket, alert: "Vous ne pouvez pas modifier ce ticket."
    end
  end

  def update
    if @support_ticket.can_be_edited_by?(current_user) && @support_ticket.update(support_ticket_params)
      redirect_to @support_ticket, notice: "Ticket mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @support_ticket.user == current_user && @support_ticket.status == 'open'
      @support_ticket.destroy
      redirect_to support_tickets_path, notice: "Ticket supprimé avec succès."
    else
      redirect_to @support_ticket, alert: "Vous ne pouvez pas supprimer ce ticket."
    end
  end

  def close
    if @support_ticket.user == current_user && @support_ticket.open?
      @support_ticket.close!
      redirect_to @support_ticket, notice: "Ticket fermé avec succès."
    else
      redirect_to @support_ticket, alert: "Impossible de fermer ce ticket."
    end
  end

  def reopen
    if @support_ticket.can_be_edited_by?(current_user) && @support_ticket.closed?
      @support_ticket.reopen!
      redirect_to @support_ticket, notice: "Ticket rouvert avec succès."
    else
      redirect_to @support_ticket, alert: "Impossible de rouvrir ce ticket."
    end
  end

  def rate
    rating = params[:rating].to_i
    feedback = params[:feedback]
    
    if rating.between?(1, 5) && @support_ticket.status == 'resolved'
      @support_ticket.add_satisfaction_rating!(rating, feedback)
      redirect_to @support_ticket, notice: "Merci pour votre évaluation !"
    else
      redirect_to @support_ticket, alert: "Évaluation invalide."
    end
  end

  private

  def set_support_ticket
    @support_ticket = SupportTicket.find(params[:id])
  end

  def check_ticket_access
    unless @support_ticket.can_be_viewed_by?(current_user)
      redirect_to support_tickets_path, alert: "Vous n'avez pas accès à ce ticket."
    end
  end

  def support_ticket_params
    params.require(:support_ticket).permit(
      :title, :description, :category, :priority,
      attachments: []
    )
  end

  def auto_assign_if_urgent
    return unless @support_ticket.priority == 'urgent'
    
    # Find available support agents (implement your logic here)
    available_agent = User.where(admin: true).first # Simplified logic
    
    if available_agent
      @support_ticket.assign_to!(available_agent)
    end
  end

  def mark_messages_as_read
    unread_messages = @support_ticket.unread_messages_for(current_user)
    unread_messages.find_each do |message|
      message.mark_as_read_by!(current_user)
    end
  end
end
