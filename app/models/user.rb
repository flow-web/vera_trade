class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable

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
  has_many :bids, foreign_key: :bidder_id, dependent: :destroy

  has_many :search_presets, dependent: :destroy
  has_many :kyc_documents, dependent: :destroy

  validates :phone, uniqueness: { message: "est déjà utilisé par un autre compte" }, allow_blank: true

  # Virtual attribute — CGU acceptance on sign-up (not persisted)
  attribute :terms_accepted, :boolean
  validates :terms_accepted, acceptance: { accept: true, message: "Vous devez accepter les CGU" }, on: :create

  KYC_STATUSES = %w[none pending verified rejected].freeze
  REQUIRED_KYC_DOCUMENTS = %w[identity_card proof_of_address].freeze

  after_create :create_wallet

  scope :with_active_listings, -> { joins(:listings).where(listings: { status: "active" }).distinct }
  scope :kyc_verified, -> { where(kyc_status: "verified") }
  scope :kyc_pending, -> { where(kyc_status: "pending") }

  def active_listings_count
    listings.where(status: "active").count
  end

  def unread_message_count
    received_messages.unread.count
  end

  def kyc_verified?
    kyc_status == "verified"
  end

  def kyc_pending?
    kyc_status == "pending"
  end

  def kyc_submitted?
    kyc_status.present? && kyc_status != "none"
  end

  def kyc_missing_documents
    REQUIRED_KYC_DOCUMENTS - kyc_documents.approved.pluck(:document_type)
  end

  def update_kyc_status!
    if REQUIRED_KYC_DOCUMENTS.all? { |type| kyc_documents.approved.exists?(document_type: type) }
      update!(kyc_status: "verified")
    elsif kyc_documents.rejected.any? && kyc_documents.pending.none?
      update!(kyc_status: "rejected")
    elsif kyc_documents.pending.any?
      update!(kyc_status: "pending")
    end
  end

  def admin?
    role == 1
  end

  def otp_required_for_login?
    otp_required_for_login
  end

  def display_name
    [ first_name, last_name ].compact.join(" ").presence || email.split("@").first
  end

  # Privacy-safe public name: "Sophie M." instead of "Sophie Martin"
  def public_display_name
    return "Vendeur" if first_name.blank? && last_name.blank?
    first = first_name.presence || "Vendeur"
    initial = last_name.present? ? " #{last_name[0].upcase}." : ""
    "#{first}#{initial}"
  end

  private

  def create_wallet
    create_wallet!(balance: 0)
  end
end
