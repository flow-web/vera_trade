class UserProfile < ApplicationRecord
  belongs_to :user
  
  validates :name, presence: true
  validates :profile_type, presence: true
  validates :access_level, presence: true
  validate :only_one_main_profile_per_user
  
  # Types de profils
  enum :profile_type, {
    personal: 'personal',
    business_owner: 'business_owner',
    employee: 'employee',
    manager: 'manager',
    sales: 'sales',
    support: 'support'
  }, default: 'personal'
  
  # Niveaux d'accès
  enum :access_level, {
    full_access: 'full',           # Accès complet (propriétaire)
    manager_access: 'manager',     # Gestion équipe + stats
    sales_only: 'sales_only',      # Vente uniquement
    support_only: 'support_only',  # Support client uniquement
    read_only: 'read_only'         # Lecture seule
  }, default: 'full_access'
  
  scope :main_profiles, -> { where(is_main: true) }
  scope :employee_profiles, -> { where(is_main: false) }
  scope :by_department, ->(dept) { where(department: dept) }
  
  before_save :set_permissions_based_on_access_level
  
  def permissions_hash
    return {} if permissions.blank?
    JSON.parse(permissions)
  rescue JSON::ParserError
    {}
  end
  
  def permissions_hash=(hash)
    self.permissions = hash.to_json
  end
  
  def can_access?(resource)
    perms = permissions_hash
    return true if full_access?
    
    case resource
    when 'wallet_full'
      full_access? || manager_access?
    when 'wallet_read'
      !read_only?
    when 'settings'
      full_access?
    when 'employee_management'
      full_access? || manager_access?
    when 'create_listings'
      full_access? || manager_access? || sales_only?
    when 'manage_messages'
      !read_only?
    when 'view_analytics'
      full_access? || manager_access? || sales_only?
    else
      perms[resource.to_s] == true
    end
  end
  
  def display_name
    name.presence || user.email
  end
  
  def initials
    display_name.split(' ').map(&:first).join('').upcase[0..1]
  end
  
  private
  
  def only_one_main_profile_per_user
    if is_main? && user.user_profiles.where(is_main: true).where.not(id: id).exists?
      errors.add(:is_main, "Un seul profil principal autorisé par utilisateur")
    end
  end
  
  def set_permissions_based_on_access_level
    base_permissions = case access_level
    when 'full_access'
      {
        'wallet_full' => true,
        'settings' => true,
        'employee_management' => true,
        'create_listings' => true,
        'manage_messages' => true,
        'view_analytics' => true,
        'delete_account' => true
      }
    when 'manager_access'
      {
        'wallet_read' => true,
        'employee_management' => true,
        'create_listings' => true,
        'manage_messages' => true,
        'view_analytics' => true
      }
    when 'sales_only'
      {
        'create_listings' => true,
        'manage_messages' => true,
        'view_analytics' => true
      }
    when 'support_only'
      {
        'manage_messages' => true,
        'view_basic_analytics' => true
      }
    when 'read_only'
      {
        'view_basic_info' => true
      }
    else
      {}
    end
    
    # Merge avec les permissions existantes si elles existent
    current_perms = permissions_hash
    self.permissions_hash = base_permissions.merge(current_perms)
  end
end
