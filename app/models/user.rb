class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :listings, dependent: :destroy
  has_many :vehicles, through: :listings
  
  has_many :conversations, foreign_key: :user_id, dependent: :destroy
  has_many :other_conversations, class_name: 'Conversation', foreign_key: :other_user_id, dependent: :destroy
  has_many :messages, foreign_key: :sender_id, dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: :recipient_id, dependent: :destroy
  has_many :message_templates, dependent: :destroy

  has_one :wallet, dependent: :destroy
  has_many :wallet_transactions, through: :wallet
  
  has_many :search_presets, dependent: :destroy

  # Nouvelles associations
  has_many :calendar_events, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :user_profiles, dependent: :destroy
  has_many :favorites, dependent: :destroy

  # Associations pour les services
  has_one :service_provider, dependent: :destroy
  has_many :service_bookings, dependent: :destroy
  has_many :service_reviews, dependent: :destroy
  has_many :service_requests, dependent: :destroy

  after_create :create_wallet, :create_default_message_templates, :create_main_profile, :create_welcome_notification

  def other_users
    User.where.not(id: id)
  end
  
  def all_conversations
    Conversation.where("user_id = ? OR other_user_id = ?", id, id)
  end
  
  def unread_messages_count
    received_messages.where(read: false).count
  end
  
  def active_conversations
    all_conversations.active_for_user(self).includes(:messages, :listing, :user, :other_user).recent_activity
  end
  
  def archived_conversations
    all_conversations.archived_for_user(self).includes(:messages, :listing, :user, :other_user).recent_activity
  end

  def wallet_balance
    wallet&.balance || 0
  end
  
  # Méthodes pour les profils multiples
  def main_profile
    user_profiles.find_by(is_main: true) || user_profiles.first
  end
  
  def current_profile
    @current_profile ||= main_profile
  end
  
  def current_profile=(profile)
    @current_profile = profile if user_profiles.include?(profile)
  end
  
  def can_access?(resource)
    current_profile&.can_access?(resource) || false
  end
  
  # Méthodes pour les notifications
  def unread_notifications_count
    notifications.unread.active.count
  end
  
  def urgent_notifications
    notifications.urgent.active.recent.limit(5)
  end
  
  # Méthodes pour le calendrier
  def upcoming_events(limit = 5)
    calendar_events.upcoming.order(:start_time).limit(limit)
  end
  
  def events_today
    calendar_events.today
  end
  
  # Méthodes pour les favoris
  def favorite_listings
    favorites.listings.includes(:favoritable).recent
  end
  
  def add_to_favorites(object, name: nil, notes: nil)
    favorites.find_or_create_by(favoritable: object) do |fav|
      fav.name = name if name.present?
      fav.notes = notes if notes.present?
    end
  end
  
  def remove_from_favorites(object)
    favorites.find_by(favoritable: object)&.destroy
  end
  
  def has_favorited?(object)
    favorites.exists?(favoritable: object)
  end

  # Méthodes pour les services
  def is_service_provider?
    service_provider.present? && service_provider.active?
  end

  def can_provide_services?
    is_service_provider?
  end

  def pending_service_bookings
    service_bookings.pending.recent.limit(5)
  end

  def active_service_requests
    service_requests.open.recent.limit(5)
  end

  private

  def create_wallet
    create_wallet!(balance: 0)
  end
  
  def create_default_message_templates
    MessageTemplate.create_defaults_for_user(self)
  end
  
  def create_main_profile
    user_profiles.create!(
      name: email.split('@').first.humanize,
      profile_type: 'personal',
      is_main: true,
      access_level: 'full_access'
    )
  end
  
  def create_welcome_notification
    notifications.create!(
      title: "Bienvenue sur VeraTrade !",
      message: "Votre compte a été créé avec succès. Découvrez toutes les fonctionnalités disponibles.",
      notification_type: 'success',
      priority: 'normal'
    )
  end
end
