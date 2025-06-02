# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Création des catégories principales
categories = {
  'Voitures' => {
    icon: 'car',
    subcategories: [
      'Berline', 'SUV', 'Coupé', 'Break', 'Monospace', 'Citadine', 'Cabriolet', 'Roadster',
      'Pick-up', 'Limousine', 'Compacte', 'SUV Compact', 'SUV Coupé', 'Voiture de sport',
      'Muscle Car', 'Hypercar', 'Grand Tourisme (GT)', 'Voiture électrique (EV)',
      'Voiture hybride (HEV)', 'SUV Hybride/Électrique', 'Microcar/Kei Car', 'Crossover',
      'Fourgonnette', 'Familiale', 'Sous-compacte', 'Voiture autonome',
      'Voiture à hydrogène (FCV)', 'Hot Hatch', 'Utilitaire Sport de Luxe',
      'Voiture de collection', 'Voiture GPL / GNV', 'Kit car / Réplique',
      'Véhicule 6 places et plus / Ludospace', 'Voiture blindée',
      'Voiture présidentielle / officielle', 'Voiture PMR (adapté handicap)',
      'Voiture école (double commande)', 'Voiture funéraire / Corbillard'
    ]
  },
  'Motos' => {
    icon: 'motorcycle',
    subcategories: [
      'Moto de route', 'Sportive', 'Routière', 'Custom', 'Trail', 'Enduro', 'Cross',
      'Scooter', 'Maxi-Scooter', 'Moto électrique', 'Trail routier', 'Sport-Touring',
      'Café Racer', 'Bobber', 'Chopper', 'Supermotard', 'Trike', 'Side-car',
      'Mobylette/Cyclomoteur', 'Dirt Bike', 'Moto vintage / néo-rétro', 'Moto trial',
      'Moto militaire', 'Moto PMR', 'Pocket bike / Mini moto', 'Moto automatique / semi-auto'
    ]
  },
  'Bateaux' => {
    icon: 'ship',
    subcategories: [
      'Voilier monocoque', 'Catamaran', 'Trimaran', 'Yacht à voile', 'Yacht à moteur',
      'Péniche', 'Bateau de pêche', 'Bateau de plaisance à moteur', 'Canot à moteur',
      'Bateau pneumatique', 'Kayak', 'Canoë', 'Jet ski/Motomarine', 'Houseboat',
      'Ferry', 'Remorqueur', 'Barge', 'Hydroptère', 'Hovercraft', 'Voilier habitable',
      'Bateau semi-rigide', 'Bateau taxi / navette', 'Pédalo', 'Paddle rigide',
      'Paddle gonflable', 'Bateau utilitaire fluvial', 'Bateau école',
      'Bateau de sauvetage', 'Remorqueur portuaire', 'Navire militaire',
      'Sous-marin de plaisance'
    ]
  },
  'Engins de chantier' => {
    icon: 'truck',
    subcategories: [
      'Excavatrice', 'Chargeuse sur pneus', 'Bulldozer', 'Niveleuse', 'Compacteur',
      'Grue mobile', 'Grue à tour', 'Chariot élévateur', 'Tractopelle', 'Foreuse',
      'Finisseur', 'Pompe à béton', 'Bétonnière automotrice', 'Dumper', 'Décapeuse',
      'Raboteuse', 'Fraiseuse', 'Trancheuse', 'Pilonneuse', 'Foreuse directionnelle',
      'Plateforme élévatrice mobile', 'Nacelle élévatrice', 'Camion-citerne',
      'Camion-balayeuse', 'Camion d\'arrosage', 'Camion de pompiers', 'Ambulances',
      'Camion de dépannage', 'Véhicule de chantier modulaire', 'Souffleuse à neige',
      'Télescopique (Manitou)', 'Chargeuse compacte', 'Élévateur tout-terrain',
      'Pelle araignée', 'Robot de démolition', 'Tarière mécanique',
      'Brise-roche hydraulique', 'Camion nacelle', 'Camion grumier',
      'Camion plateau-grue', 'Camion atelier / laboratoire', 'Camion de secours / 4x4 lourd'
    ]
  },
  'Aéronefs' => {
    icon: 'plane',
    subcategories: [
      'Avion de ligne', 'Avion de transport de fret', 'Avion de tourisme',
      'Avion d\'affaires', 'Avion de chasse', 'Bombardier', 'Avion de reconnaissance',
      'Avion de transport militaire', 'Avion d\'entraînement', 'Hydravion',
      'Amphibie', 'Avion à hélices', 'Avion à réaction', 'Avion à turbopropulseur',
      'ULM', 'Planeur', 'Motoplaneur', 'Avion de voltige', 'Avion expérimental',
      'Drone/UAV', 'Hydravion biplan', 'Paramoteur', 'Parapente motorisé',
      'Autogire / Gyrocoptère', 'Avion cargo civil', 'Drone de loisir',
      'Drone agricole', 'Drone industriel'
    ]
  },
  'Véhicules agricoles' => {
    icon: 'tractor',
    subcategories: [
      'Tracteur agricole', 'Moissonneuse-batteuse', 'Semoir', 'Pulvérisateur',
      'Charrue', 'Herse', 'Rouleau', 'Faucheuse', 'Andaineur', 'Presse à balles',
      'Enrubanneuse', 'Distributeur d\'aliments', 'Tracteur viticole',
      'Tracteur forestier', 'Tracteur tondeuse autoportée', 'Robot tondeuse / agricole',
      'Véhicule agricole à chenilles', 'Engin forestier', 'Engin minier',
      'Véhicule forestier téléguidé', 'Motoculteur motorisé', 'Débroussailleuse tractée',
      'Tondeuse autoportée pro', 'Tondeuse frontale 4x4'
    ]
  },
  'Véhicules spéciaux' => {
    icon: 'truck',
    subcategories: [
      'Véhicule de transport de détenus', 'Véhicule d\'intervention rapide',
      'Véhicule de presse / radio', 'Véhicule de tournée commerciale',
      'Véhicule podium / promotion', 'Véhicule sonorisé / sono mobile',
      'Véhicule événementiel / food truck', 'Véhicule frigorifique autonome',
      'Véhicule musée / collection mobile', 'Véhicule showroom / vitrine mobile',
      'Véhicule de détection', 'Véhicule de désamiantage',
      'Véhicule de nettoyage industriel', 'Véhicule anti-émeute',
      'Véhicule blindé léger', 'Véhicule d\'expédition',
      'Véhicule pour défilé / cortège', 'Véhicule de rallye-raid d\'assistance',
      'Véhicule de chantier léger 4x4', 'Véhicule de secours minier',
      'Véhicule à chenilles', 'Véhicule à air comprimé',
      'Véhicule à hydrogène utilitaire', 'Véhicule solaire',
      'Micro-voiture urbaine autonome', 'Voiture sans permis utilitaire'
    ]
  },
  'Remorques et caravanes' => {
    icon: 'trailer',
    subcategories: [
      'Remorque utilitaire', 'Remorque porte-voiture', 'Remorque porte-moto',
      'Remorque frigorifique', 'Remorque agricole', 'Camping-car',
      'Van aménagé', 'Caravane', 'Remorque magasin / boutique',
      'Remorque snack / food truck', 'Remorque sanitaire / toilettes mobiles',
      'Remorque scène mobile', 'Remorque tribune / loge mobile',
      'Remorque événementielle'
    ]
  }
}

# Création des catégories et sous-catégories
categories.each do |name, data|
  category = Category.create!(
    name: name,
    icon: data[:icon],
    description: "Trouvez votre #{name.downcase} idéal parmi notre sélection"
  )
  
  data[:subcategories].each do |subname|
    Category.create!(
      name: subname,
      parent_id: category.id,
      description: "Découvrez notre sélection de #{subname.downcase}s"
    )
  end
end

# Création d'un utilisateur test s'il n'existe pas déjà
user = User.find_or_create_by!(email: 'test@example.com') do |u|
  u.password = 'password123'
  u.first_name = 'Jean'
  u.last_name = 'Dupont'
  u.phone = '0612345678'
end

# Données pour les annonces de voitures
car_listings = [
  {
    title: "BMW Série 3 320d M Sport - 2020",
    description: "Magnifique BMW Série 3 en parfait état, première main, entretien régulier chez BMW. Pack M Sport complet avec jantes 19 pouces, sellerie cuir, navigation professionnelle, caméra de recul, radar de stationnement, etc. CT récent, garantie constructeur encore valable.",
    make: "BMW",
    model: "Série 3",
    year: 2020,
    price: 34900,
    kilometers: 45000,
    fuel_type: "Diesel",
    transmission: "Automatique",
    finition: "M Sport",
    doors: 4,
    exterior_color: "Noir métallisé",
    interior_material: "Cuir",
    interior_color: "Noir",
    previous_owners: 1,
    has_service_history: true,
    non_smoker: true,
    location: "Paris",
    license_plate: "AB-123-CD",
    vin: "WBAPK7C50AA000001",
    fiscal_power: 6,
    average_consumption: 4.5,
    co2_emissions: 119,
    safety_features: "ABS, ESP, Airbags frontaux et latéraux, Caméra de recul, Radar de stationnement",
    comfort_features: "Climatisation automatique, Régulateur de vitesse, Volant multifonction, Sièges chauffants",
    multimedia_features: "Navigation professionnelle, Apple CarPlay, Android Auto, Haut-parleurs Harman Kardon",
    exterior_features: "Jantes 19 pouces M Sport, Phares LED, Rétroviseurs électriques, Toit ouvrant panoramique",
    body_condition: "Parfait état, pas de rayures ni de bosses",
    interior_condition: "Intérieur comme neuf, pas d'usure visible",
    tire_condition: "Pneus Michelin en bon état, 70% d'usure restante",
    recent_works: "Vidange récente, Filtres changés, Freins révisés"
  },
  {
    title: "Renault Clio V Intens - 2021",
    description: "Renault Clio V Intens en excellent état, deuxième main, entretien régulier. Version Intens avec jantes 17 pouces, climatisation automatique, caméra de recul, radar de stationnement, etc. CT récent, garantie constructeur encore valable.",
    make: "Renault",
    model: "Clio",
    year: 2021,
    price: 18900,
    kilometers: 32000,
    fuel_type: "Essence",
    transmission: "Manuelle",
    finition: "Intens",
    doors: 5,
    exterior_color: "Gris métallisé",
    interior_material: "Tissu",
    interior_color: "Noir",
    previous_owners: 2,
    has_service_history: true,
    non_smoker: true,
    location: "Lyon",
    license_plate: "EF-456-GH",
    vin: "VF1RJA00X67000001",
    fiscal_power: 5,
    average_consumption: 5.2,
    co2_emissions: 120,
    safety_features: "ABS, ESP, Airbags frontaux et latéraux, Caméra de recul, Radar de stationnement",
    comfort_features: "Climatisation automatique, Régulateur de vitesse, Volant multifonction",
    multimedia_features: "Écran tactile 9.3 pouces, Apple CarPlay, Android Auto, Radio DAB",
    exterior_features: "Jantes 17 pouces, Phares LED, Rétroviseurs électriques",
    body_condition: "Très bon état, quelques micro-rayures",
    interior_condition: "Intérieur en très bon état",
    tire_condition: "Pneus Continental en bon état, 60% d'usure restante",
    recent_works: "Vidange récente, Filtres changés"
  }
]

# Données pour les annonces de motos
motorcycle_listings = [
  {
    title: "BMW R 1250 GS Adventure - 2022",
    description: "BMW R 1250 GS Adventure en parfait état, première main. Version Adventure avec tous les équipements : selle chauffante, GPS intégré, suspensions électroniques, etc. Entretien régulier chez BMW, garantie constructeur encore valable.",
    make: "BMW",
    model: "R 1250 GS Adventure",
    year: 2022,
    price: 22900,
    kilometers: 12000,
    fuel_type: "Essence",
    transmission: "Manuelle",
    finition: "Adventure",
    exterior_color: "Rallye",
    interior_material: "Cuir",
    previous_owners: 1,
    has_service_history: true,
    location: "Marseille",
    license_plate: "IJ-789-KL",
    vin: "WB10A0200A0000001",
    fiscal_power: 12,
    average_consumption: 5.8,
    co2_emissions: 135,
    safety_features: "ABS Pro, ASC, DTC, DBC, HSC",
    comfort_features: "Selle chauffante, Suspensions électroniques, Contrôle de vitesse",
    multimedia_features: "GPS intégré, Bluetooth, Radio",
    exterior_features: "Protections moteur, Garde-boue avant rallongé, Selle haute",
    body_condition: "Parfait état, pas de rayures ni de bosses",
    interior_condition: "Intérieur comme neuf",
    tire_condition: "Pneus Anakee Adventure en bon état, 80% d'usure restante",
    recent_works: "Vidange récente, Filtres changés, Révision complète"
  }
]

# Données pour les annonces de bateaux
boat_listings = [
  {
    title: "Jeanneau Cap Camarat 5.5 - 2021",
    description: "Jeanneau Cap Camarat 5.5 en excellent état, première main. Bateau équipé avec moteur Suzuki 115CV, GPS, sondeur, etc. Entretien régulier, garantie constructeur encore valable.",
    make: "Jeanneau",
    model: "Cap Camarat 5.5",
    year: 2021,
    price: 45900,
    fuel_type: "Essence",
    transmission: "Arbre",
    finition: "Weekender",
    exterior_color: "Blanc",
    previous_owners: 1,
    has_service_history: true,
    location: "Nice",
    license_plate: "MN-012-OP",
    vin: "FR1JN00X670000018",
    length: 5.5,
    width: 2.3,
    draft: 0.5,
    hull_material: "Polyester",
    number_of_cabins: 1,
    number_of_berths: 2,
    engine_hours: 120,
    safety_features: "GPS, Sondeur, Radio VHF, Gilets de sauvetage",
    comfort_features: "Cockpit confortable, Table à manger, Douche",
    multimedia_features: "Enceintes Bluetooth, Prise USB",
    exterior_features: "Bimini, Store de cockpit, Échelle de bain",
    body_condition: "Parfait état, pas de rayures ni d'impacts",
    interior_condition: "Intérieur comme neuf",
    recent_works: "Révision moteur récente, Antifouling récent"
  }
]

# Données pour les annonces d'engins de chantier
construction_listings = [
  {
    title: "Caterpillar 320D2 - 2019",
    description: "Caterpillar 320D2 en excellent état, bien entretenu. Pelle mécanique équipée avec godet standard, climatisation, radio, etc. Heures moteur vérifiées, entretien régulier.",
    make: "Caterpillar",
    model: "320D2",
    year: 2019,
    price: 125000,
    fuel_type: "Diesel",
    transmission: "Automatique",
    finition: "Standard",
    exterior_color: "Jaune",
    previous_owners: 2,
    has_service_history: true,
    location: "Lille",
    license_plate: "QR-345-ST",
    vin: "CAT320D2X67000001",
    operating_hours: 4500,
    lifting_capacity: 8.5,
    bucket_capacity: 1.2,
    safety_features: "Caméra de recul, Alarme, Éclairage LED",
    comfort_features: "Climatisation, Radio, Siège confortable",
    multimedia_features: "Écran LCD, Radio CD",
    exterior_features: "Godet standard, Lame de nivellement, Protection cabine",
    body_condition: "Très bon état, quelques traces d'usure normales",
    interior_condition: "Cabine en bon état",
    recent_works: "Révision complète, Filtres changés, Huiles changées"
  }
]

# Création des annonces
[car_listings, motorcycle_listings, boat_listings, construction_listings].each do |listings|
  listings.each do |listing_data|
    puts "Création de l'annonce #{listing_data[:title]}"
    # Création du véhicule
    vehicle = Vehicle.create!(
      listing_data.except(:title, :description)
    )
    
    # Création de l'annonce
    listing = Listing.create!(
      title: listing_data[:title],
      description: listing_data[:description],
      user: user,
      vehicle: vehicle,
      status: 'active'
    )

    # Ajout des images
    case listing_data[:make]
    when "BMW"
      if listing_data[:model].include?("Série 3")
        # Images pour BMW Série 3
        listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/bmw_serie3_1.jpg")), filename: "bmw_serie3_1.jpg")
        listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/bmw_serie3_2.jpg")), filename: "bmw_serie3_2.jpg")
        listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/bmw_serie3_3.jpg")), filename: "bmw_serie3_3.jpg")
      elsif listing_data[:model].include?("R 1250")
        # Images pour BMW R 1250 GS
        listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/bmw_r1250_1.jpg")), filename: "bmw_r1250_1.jpg")
        listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/bmw_r1250_2.jpg")), filename: "bmw_r1250_2.jpg")
        listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/bmw_r1250_3.jpg")), filename: "bmw_r1250_3.jpg")
      end
    when "Renault"
      # Images pour Renault Clio
      listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/renault_clio_1.jpg")), filename: "renault_clio_1.jpg")
      listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/renault_clio_2.jpg")), filename: "renault_clio_2.jpg")
      listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/renault_clio_3.jpg")), filename: "renault_clio_3.jpg")
    when "Jeanneau"
      # Images pour Jeanneau Cap Camarat
      listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/jeanneau_capcamarat_1.jpg")), filename: "jeanneau_capcamarat_1.jpg")
      listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/jeanneau_capcamarat_2.jpg")), filename: "jeanneau_capcamarat_2.jpg")
      listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/jeanneau_capcamarat_3.jpg")), filename: "jeanneau_capcamarat_3.jpg")
    when "Caterpillar"
      # Images pour Caterpillar 320D2
      listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/caterpillar_320d2_1.jpg")), filename: "caterpillar_320d2_1.jpg")
      listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/caterpillar_320d2_2.jpg")), filename: "caterpillar_320d2_2.jpg")
      listing.photos.attach(io: File.open(Rails.root.join("app/assets/images/seed/caterpillar_320d2_3.jpg")), filename: "caterpillar_320d2_3.jpg")
    end
  end
end

puts "Seed terminé avec succès !"

# Création d'un utilisateur de test si il n'existe pas
user = User.find_or_create_by(email: 'test@example.com') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
end

puts "Utilisateur de test créé : #{user.email}"

# Vérifier que le profil principal a été créé
main_profile = user.main_profile
if main_profile
  puts "Profil principal créé : #{main_profile.display_name}"
else
  puts "Création du profil principal..."
  main_profile = user.user_profiles.create!(
    name: user.email.split('@').first.humanize,
    profile_type: 'personal',
    is_main: true,
    access_level: 'full_access'
  )
end

# Créer quelques profils d'employés pour démontrer le système multi-profils
unless user.user_profiles.count > 1
  puts "Création de profils d'employés..."
  
  # Profil manager
  manager_profile = user.user_profiles.create!(
    name: 'Jean Dupont',
    profile_type: 'manager',
    position: 'Directeur des ventes',
    department: 'Ventes',
    is_main: false,
    access_level: 'manager_access'
  )
  
  # Profil vendeur
  sales_profile = user.user_profiles.create!(
    name: 'Marie Martin',
    profile_type: 'sales',
    position: 'Conseillère commerciale',
    department: 'Ventes',
    is_main: false,
    access_level: 'sales_only'
  )
  
  # Profil support
  support_profile = user.user_profiles.create!(
    name: 'Pierre Durand',
    profile_type: 'support',
    position: 'Agent support',
    department: 'Support client',
    is_main: false,
    access_level: 'support_only'
  )
  
  puts "Profils d'employés créés : #{user.user_profiles.count} profils au total"
end

# Créer des événements de calendrier d'exemple
unless user.calendar_events.any?
  puts "Création d'événements de calendrier..."
  
  # Événement aujourd'hui
  user.calendar_events.create!(
    title: "Appel client - Vente BMW X3",
    description: "Appel programmé avec M. Leblanc pour finaliser la vente",
    event_type: 'video_call',
    start_time: DateTime.current.change(hour: 14, min: 0),
    end_time: DateTime.current.change(hour: 14, min: 30),
    color: '#3B82F6'
  )
  
  # Événement demain
  user.calendar_events.create!(
    title: "Réunion équipe commerciale",
    description: "Point hebdomadaire avec l'équipe de vente",
    event_type: 'meeting',
    start_time: DateTime.current.tomorrow.change(hour: 9, min: 0),
    end_time: DateTime.current.tomorrow.change(hour: 10, min: 0),
    color: '#10B981'
  )
  
  # Rappel dans 3 jours
  user.calendar_events.create!(
    title: "Rappel - Livraison Mercedes Classe A",
    description: "Vérifier que la livraison s'est bien passée",
    event_type: 'reminder',
    start_time: 3.days.from_now.change(hour: 10, min: 0),
    end_time: 3.days.from_now.change(hour: 10, min: 15),
    color: '#F59E0B'
  )
  
  # Rendez-vous la semaine prochaine
  user.calendar_events.create!(
    title: "RDV garage - Inspection Audi A4",
    description: "Inspection pré-vente chez le garage partenaire",
    event_type: 'appointment',
    start_time: 1.week.from_now.change(hour: 14, min: 0),
    end_time: 1.week.from_now.change(hour: 16, min: 0),
    color: '#8B5CF6'
  )
  
  puts "#{user.calendar_events.count} événements de calendrier créés"
end

# Créer des notifications d'exemple
unless user.notifications.any?
  puts "Création de notifications..."
  
  # Notification urgente
  user.notifications.create!(
    title: "Nouveau message urgent",
    message: "Vous avez reçu un message important concernant la vente de votre Renault Clio",
    notification_type: 'message',
    priority: 'urgent',
    read: false,
    action_url: '/messages'
  )
  
  # Notification de succès
  user.notifications.create!(
    title: "Vente réalisée !",
    message: "Félicitations ! Votre BMW X1 a été vendue pour 25 000€",
    notification_type: 'success',
    priority: 'high',
    read: false
  )
  
  # Notification de rappel
  user.notifications.create!(
    title: "Rappel - Appel vidéo dans 1h",
    message: "N'oubliez pas votre appel vidéo avec M. Leblanc à 14h00",
    notification_type: 'video_call',
    priority: 'normal',
    read: false,
    expires_at: DateTime.current + 2.hours
  )
  
  # Notification d'information
  user.notifications.create!(
    title: "Mise à jour de votre annonce",
    message: "Votre annonce Peugeot 308 a été mise à jour avec succès",
    notification_type: 'listing_update',
    priority: 'low',
    read: true,
    created_at: 2.days.ago
  )
  
  # Notification de contrat
  user.notifications.create!(
    title: "Contrat à signer",
    message: "Le contrat de vente pour la Ford Focus est prêt à être signé",
    notification_type: 'contract',
    priority: 'high',
    read: false,
    action_url: '/contracts/123'
  )
  
  puts "#{user.notifications.count} notifications créées"
end

# Créer quelques favoris d'exemple si des listings existent
if Listing.any? && user.favorites.empty?
  puts "Création de favoris..."
  
  Listing.limit(3).each do |listing|
    user.add_to_favorites(
      listing,
      name: "Favori - #{listing.title}",
      notes: "Ajouté automatiquement lors du seed"
    )
  end
  
  puts "#{user.favorites.count} favoris créés"
end

puts "\n=== Résumé des données créées ==="
puts "👤 Utilisateur : #{user.email}"
puts "📋 Profils : #{user.user_profiles.count}"
puts "📅 Événements : #{user.calendar_events.count}"
puts "🔔 Notifications : #{user.notifications.count}"
puts "❤️ Favoris : #{user.favorites.count}"
puts "\n✅ Données de démonstration créées avec succès !"
puts "\nConnectez-vous avec :"
puts "Email: #{user.email}"
puts "Mot de passe: password123"
