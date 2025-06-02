class ServiceProvidersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_service_provider, only: [:show, :edit, :update, :destroy]
  before_action :ensure_owner, only: [:edit, :update, :destroy]

  def index
    redirect_to services_path
  end

  def show
    @service_offers = @service_provider.service_offers.active.includes(:category)
    @service_reviews = @service_provider.service_reviews.recent.includes(:user).limit(10)
    @service_bookings = @service_provider.service_bookings.recent.limit(5) if current_user == @service_provider.user
  end

  def new
    @service_provider = current_user.build_service_provider
    @categories = Category.all
  end

  def create
    @service_provider = current_user.build_service_provider(service_provider_params)
    @categories = Category.all

    if @service_provider.save
      # Associer les catégories sélectionnées
      if params[:category_ids].present?
        params[:category_ids].each do |category_id|
          @service_provider.service_categories.create(category_id: category_id)
        end
      end

      redirect_to @service_provider, notice: 'Votre profil de prestataire a été créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.all
    @selected_categories = @service_provider.categories.pluck(:id)
  end

  def update
    if @service_provider.update(service_provider_params)
      # Mettre à jour les catégories
      @service_provider.service_categories.destroy_all
      if params[:category_ids].present?
        params[:category_ids].each do |category_id|
          @service_provider.service_categories.create(category_id: category_id)
        end
      end

      redirect_to @service_provider, notice: 'Votre profil a été mis à jour avec succès.'
    else
      @categories = Category.all
      @selected_categories = @service_provider.categories.pluck(:id)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service_provider.destroy
    redirect_to dashboard_path, notice: 'Votre profil de prestataire a été supprimé.'
  end

  def dashboard
    @service_provider = current_user.service_provider
    redirect_to new_service_provider_path unless @service_provider

    @pending_bookings = @service_provider.service_bookings.pending.recent.limit(5)
    @recent_reviews = @service_provider.service_reviews.recent.limit(3)
    @monthly_stats = calculate_monthly_stats
    @service_offers = @service_provider.service_offers.active.limit(5)
  end

  private

  def set_service_provider
    @service_provider = ServiceProvider.find(params[:id])
  end

  def ensure_owner
    redirect_to services_path unless current_user == @service_provider.user
  end

  def service_provider_params
    params.require(:service_provider).permit(
      :business_name, :description, :phone, :address, :city, :postal_code,
      :latitude, :longitude, :specialties, :website, :profile_image,
      :cv_document, portfolio_images: [], certificates: []
    )
  end

  def calculate_monthly_stats
    current_month = Date.current.beginning_of_month
    {
      bookings_count: @service_provider.service_bookings.where(created_at: current_month..).count,
      revenue: @service_provider.service_bookings.completed.where(created_at: current_month..).sum(:total_amount),
      reviews_count: @service_provider.service_reviews.where(created_at: current_month..).count,
      average_rating: @service_provider.service_reviews.where(created_at: current_month..).average(:rating) || 0
    }
  end
end 