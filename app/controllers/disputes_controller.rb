class DisputesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dispute, only: [:show, :edit, :update, :destroy, :escalate, :resolve, :reopen]
  before_action :check_dispute_access, only: [:show, :edit, :update, :destroy]

  def index
    @disputes = current_user.disputes.includes(:disputed_item, :mediator)
                           .order(created_at: :desc)
    
    # Apply pagination if available
    @disputes = @disputes.page(params[:page]) if @disputes.respond_to?(:page)
    
    # Filter by status if provided
    @disputes = @disputes.by_status(params[:status]) if params[:status].present?
    
    # Filter by type if provided
    @disputes = @disputes.by_type(params[:dispute_type]) if params[:dispute_type].present?
    
    # Filter by priority if provided
    @disputes = @disputes.by_priority(params[:priority]) if params[:priority].present?
    
    @dispute_counts = {
      open: current_user.disputes.open.count,
      closed: current_user.disputes.closed.count,
      urgent: current_user.disputes.urgent.count
    }
  end

  def show
    @dispute_messages = @dispute.dispute_messages
                               .visible_to(current_user)
                               .includes(:user, :attachments)
                               .order(:created_at)
    
    @dispute_evidences = @dispute.dispute_evidences
                                .includes(:user, :files)
                                .order(:created_at)
    
    @dispute_resolutions = @dispute.dispute_resolutions
                                  .includes(:proposed_by)
                                  .order(:created_at)
    
    @new_message = @dispute.dispute_messages.build
    @new_evidence = @dispute.dispute_evidences.build
    @new_resolution = @dispute.dispute_resolutions.build
    
    # Mark messages as read
    mark_messages_as_read
  end

  def new
    @dispute = current_user.disputes.build
    @disputed_item = find_disputed_item
    
    if @disputed_item
      @dispute.disputed_item = @disputed_item
    else
      redirect_to root_path, alert: "Objet du litige non trouvé."
      return
    end
  end

  def create
    @dispute = current_user.disputes.build(dispute_params)
    @disputed_item = find_disputed_item
    @dispute.disputed_item = @disputed_item if @disputed_item

    if @dispute.save
      redirect_to @dispute, notice: "Litige créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Only allow editing if dispute is open and user has permission
    unless @dispute.can_be_edited_by?(current_user)
      redirect_to @dispute, alert: "Vous ne pouvez pas modifier ce litige."
    end
  end

  def update
    if @dispute.can_be_edited_by?(current_user) && @dispute.update(dispute_params)
      redirect_to @dispute, notice: "Litige mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @dispute.user == current_user && @dispute.status == 'open'
      @dispute.update!(status: 'cancelled')
      redirect_to disputes_path, notice: "Litige annulé avec succès."
    else
      redirect_to @dispute, alert: "Vous ne pouvez pas annuler ce litige."
    end
  end

  def escalate
    if @dispute.user == current_user && @dispute.open?
      @dispute.escalate!
      redirect_to @dispute, notice: "Litige escaladé vers la médiation."
    else
      redirect_to @dispute, alert: "Impossible d'escalader ce litige."
    end
  end

  def resolve
    if current_user.can_mediate_disputes? && @dispute.requires_mediation?
      resolution_text = params[:resolution_text]
      @dispute.resolve!(resolution_text)
      redirect_to @dispute, notice: "Litige résolu avec succès."
    else
      redirect_to @dispute, alert: "Vous n'avez pas l'autorisation de résoudre ce litige."
    end
  end

  def reopen
    if @dispute.can_be_edited_by?(current_user) && @dispute.closed?
      @dispute.reopen!
      redirect_to @dispute, notice: "Litige rouvert avec succès."
    else
      redirect_to @dispute, alert: "Impossible de rouvrir ce litige."
    end
  end

  private

  def set_dispute
    @dispute = Dispute.find(params[:id])
  end

  def check_dispute_access
    unless @dispute.can_be_viewed_by?(current_user)
      redirect_to disputes_path, alert: "Vous n'avez pas accès à ce litige."
    end
  end

  def dispute_params
    params.require(:dispute).permit(
      :title, :description, :dispute_type, :priority, :amount,
      attachments: []
    )
  end

  def find_disputed_item
    return nil unless params[:disputed_item_type] && params[:disputed_item_id]
    
    case params[:disputed_item_type]
    when 'Listing'
      Listing.find_by(id: params[:disputed_item_id])
    when 'ServiceBooking'
      ServiceBooking.find_by(id: params[:disputed_item_id])
    else
      nil
    end
  end

  def mark_messages_as_read
    unread_messages = @dispute.unread_messages_for(current_user)
    unread_messages.find_each do |message|
      message.mark_as_read_by!(current_user)
    end
  end
end
