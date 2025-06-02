class ServicesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @search_query = params[:search]
    @category_filter = params[:category]
    @location_filter = params[:location]
    @radius = params[:radius] || 50

    @service_providers = ServiceProvider.active.includes(:categories, :user, :service_reviews)
    
    # Recherche par mot-clé
    if @search_query.present?
      @service_providers = @service_providers.joins(:categories)
                                           .where("categories.name ILIKE ? OR service_providers.business_name ILIKE ? OR service_providers.description ILIKE ?", 
                                                  "%#{@search_query}%", "%#{@search_query}%", "%#{@search_query}%")
    end

    # Filtrage par catégorie
    if @category_filter.present?
      @service_providers = @service_providers.by_category(@category_filter)
    end

    # Filtrage par localisation (si coordonnées disponibles)
    if @location_filter.present? && current_user&.latitude && current_user&.longitude
      @service_providers = @service_providers.near_location(current_user.latitude, current_user.longitude, @radius.to_i)
    end

    @service_providers = @service_providers.distinct.limit(50)

    # Données pour la page d'accueil
    @popular_categories = Category.for_services.popular.limit(8)
    @verified_providers = ServiceProvider.verified.active.includes(:service_reviews).limit(6)
    @recent_providers = ServiceProvider.active.order(created_at: :desc).limit(4)
    
    respond_to do |format|
      format.html
      format.json { render json: @service_providers }
    end
  end

  def show
    @service_provider = ServiceProvider.find(params[:id])
    @service_offers = @service_provider.service_offers.active.includes(:category)
    @service_reviews = @service_provider.service_reviews.recent.includes(:user).limit(10)
    @average_rating = @service_provider.average_rating
    @total_reviews = @service_provider.total_reviews
  end

  def search
    @query = params[:q]
    @category = params[:category]
    @location = params[:location]
    
    @results = ServiceProvider.active
    
    if @query.present?
      @results = @results.joins(:categories)
                        .where("categories.name ILIKE ? OR service_providers.business_name ILIKE ? OR service_providers.description ILIKE ?", 
                               "%#{@query}%", "%#{@query}%", "%#{@query}%")
    end
    
    if @category.present?
      @results = @results.by_category(@category)
    end
    
    @results = @results.distinct.includes(:categories, :service_reviews)
    
    render json: @results.map { |provider|
      {
        id: provider.id,
        business_name: provider.business_name,
        description: provider.description.truncate(100),
        city: provider.city,
        average_rating: provider.average_rating,
        total_reviews: provider.total_reviews,
        categories: provider.categories.pluck(:name),
        badge_types: provider.badge_types
      }
    }
  end

  def map_data
    @service_providers = ServiceProvider.active.where.not(latitude: nil, longitude: nil)
    
    if params[:category].present?
      @service_providers = @service_providers.by_category(params[:category])
    end
    
    render json: @service_providers.map { |provider|
      {
        id: provider.id,
        business_name: provider.business_name,
        latitude: provider.latitude,
        longitude: provider.longitude,
        city: provider.city,
        categories: provider.categories.pluck(:name),
        average_rating: provider.average_rating,
        badge_types: provider.badge_types
      }
    }
  end
end 