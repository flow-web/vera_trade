class ServiceRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_service_request, only: [:show, :edit, :update, :destroy]
  before_action :ensure_owner, only: [:edit, :update, :destroy]

  def index
    @service_requests = ServiceRequest.open.recent.includes(:category, :listing, :user)
    
    if params[:category].present?
      @service_requests = @service_requests.by_category(params[:category])
    end
    
    if params[:budget_min].present? && params[:budget_max].present?
      @service_requests = @service_requests.in_budget_range(params[:budget_min], params[:budget_max])
    end
    
    @service_requests = @service_requests.limit(50)
    @categories = Category.joins(:service_requests).distinct
  end

  def show
    @service_request_response = ServiceRequestResponse.new
    @responses = @service_request.service_request_responses.recent.includes(:service_provider)
    @can_respond = current_user.is_service_provider? && 
                   !@service_request.service_request_responses.exists?(service_provider: current_user.service_provider)
  end

  def new
    @listing = Listing.find(params[:listing_id]) if params[:listing_id]
    @service_request = ServiceRequest.new(listing: @listing)
    @categories = Category.all
  end

  def create
    @service_request = current_user.service_requests.build(service_request_params)
    @categories = Category.all

    if @service_request.save
      # Notifier les prestataires de la catégorie concernée
      notify_relevant_providers
      redirect_to @service_request, notice: 'Votre demande de service a été créée avec succès.'
    else
      @listing = @service_request.listing
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.all
  end

  def update
    if @service_request.update(service_request_params)
      redirect_to @service_request, notice: 'Votre demande a été mise à jour.'
    else
      @categories = Category.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service_request.destroy
    redirect_to service_requests_path, notice: 'Votre demande a été supprimée.'
  end

  def my_requests
    @service_requests = current_user.service_requests.recent.includes(:category, :listing)
    @service_requests = @service_requests.limit(50)
  end

  def respond
    @service_request = ServiceRequest.find(params[:id])
    @service_request_response = ServiceRequestResponse.new(service_request_response_params)
    @service_request_response.service_request = @service_request
    @service_request_response.service_provider = current_user.service_provider

    if @service_request_response.save
      # Notifier le demandeur
      create_response_notification
      redirect_to @service_request, notice: 'Votre réponse a été envoyée avec succès.'
    else
      @responses = @service_request.service_request_responses.recent.includes(:service_provider)
      @can_respond = true
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_service_request
    @service_request = ServiceRequest.find(params[:id])
  end

  def ensure_owner
    redirect_to service_requests_path unless current_user == @service_request.user
  end

  def service_request_params
    params.require(:service_request).permit(
      :title, :description, :budget_min, :budget_max, :deadline, :urgency,
      :category_id, :listing_id
    )
  end

  def service_request_response_params
    params.require(:service_request_response).permit(
      :message, :proposed_price, :estimated_duration
    )
  end

  def notify_relevant_providers
    # Notifier les prestataires de la catégorie concernée
    ServiceProvider.active.by_category(@service_request.category_id).find_each do |provider|
      provider.user.notifications.create!(
        title: "Nouvelle demande de service",
        message: "Une nouvelle demande dans la catégorie #{@service_request.category.name} est disponible.",
        notification_type: 'info',
        priority: 'normal'
      )
    end
  end

  def create_response_notification
    @service_request.user.notifications.create!(
      title: "Nouvelle réponse à votre demande",
      message: "#{@service_request_response.service_provider.business_name} a répondu à votre demande '#{@service_request.title}'.",
      notification_type: 'info',
      priority: 'normal'
    )
  end
end 