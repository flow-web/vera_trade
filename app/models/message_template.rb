class MessageTemplate < ApplicationRecord
  belongs_to :user
  
  validates :title, presence: true
  validates :content, presence: true
  validates :category, presence: true
  
  # Categories for organizing templates
  enum :category, {
    greeting: 'greeting',
    pricing: 'pricing',
    availability: 'availability',
    meeting: 'meeting',
    closing: 'closing',
    technical: 'technical',
    custom: 'custom'
  }, default: 'custom'
  
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(updated_at: :desc) }
  
  # French translations for categories
  def self.category_in_french(category)
    translations = {
      'greeting' => 'Salutation',
      'pricing' => 'Prix',
      'availability' => 'Disponibilité',
      'meeting' => 'Rendez-vous',
      'closing' => 'Clôture',
      'technical' => 'Technique',
      'custom' => 'Personnalisé'
    }
    translations[category.to_s] || category.to_s.humanize
  end
  
  def category_in_french
    self.class.category_in_french(category)
  end
  
  # Default templates for new users
  def self.create_defaults_for_user(user)
    default_templates = [
      {
        title: "Salutation initiale",
        content: "Bonjour, je suis intéressé(e) par votre annonce. Pourriez-vous me donner plus d'informations ?",
        category: "greeting"
      },
      {
        title: "Demande de prix",
        content: "Quel est votre dernier prix pour ce véhicule ? Y a-t-il une marge de négociation ?",
        category: "pricing"
      },
      {
        title: "Disponibilité visite",
        content: "Quand puis-je venir voir le véhicule ? Je suis disponible en semaine et le week-end.",
        category: "availability"
      },
      {
        title: "Proposition rendez-vous",
        content: "Seriez-vous disponible pour un appel vidéo afin de voir le véhicule en détail ?",
        category: "meeting"
      },
      {
        title: "Remerciements",
        content: "Merci pour les informations. Je vais réfléchir et vous recontacter bientôt.",
        category: "closing"
      },
      {
        title: "Questions techniques",
        content: "Pourriez-vous me donner l'historique d'entretien et les dernières réparations effectuées ?",
        category: "technical"
      }
    ]
    
    default_templates.each do |template_data|
      user.message_templates.create!(template_data)
    end
  end
end
