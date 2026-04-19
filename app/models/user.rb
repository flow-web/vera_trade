class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :listings, dependent: :destroy
  has_many :vehicles, through: :listings
  has_many :favorites, dependent: :destroy
  has_many :favorited_listings, through: :favorites, source: :listing

  has_many :conversations, foreign_key: :user_id, dependent: :destroy
  has_many :other_conversations, class_name: "Conversation", foreign_key: :other_user_id, dependent: :destroy
  has_many :messages, foreign_key: :sender_id, dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: :recipient_id, dependent: :destroy

  has_one :wallet, dependent: :destroy
  has_many :wallet_transactions, through: :wallet

  has_many :escrows_as_buyer, class_name: "Escrow", foreign_key: :buyer_id, dependent: :restrict_with_error
  has_many :escrows_as_seller, class_name: "Escrow", foreign_key: :seller_id, dependent: :restrict_with_error

  has_many :search_presets, dependent: :destroy

  after_create :create_wallet

  scope :with_active_listings, -> { joins(:listings).where(listings: { status: "active" }).distinct }

  def active_listings_count
    listings.where(status: "active").count
  end

  def unread_message_count
    received_messages.unread.count
  end

  def display_name
    [ first_name, last_name ].compact.join(" ").presence || email.split("@").first
  end

  private

  def create_wallet
    create_wallet!(balance: 0)
  end
end
