class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favoritable, polymorphic: true
  
  validates :user_id, uniqueness: { scope: [:favoritable_type, :favoritable_id] }
  
  scope :listings, -> { where(favoritable_type: 'Listing') }
  scope :users, -> { where(favoritable_type: 'User') }
  scope :recent, -> { order(created_at: :desc) }
  
  def display_name
    name.presence || default_name
  end
  
  private
  
  def default_name
    case favoritable_type
    when 'Listing'
      favoritable&.title || 'Annonce'
    when 'User'
      favoritable&.email || 'Utilisateur'
    else
      'Favori'
    end
  end
end
