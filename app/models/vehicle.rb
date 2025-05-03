class Vehicle < ApplicationRecord
  has_many :listings, dependent: :destroy
  has_many :users, through: :listings
  belongs_to :category, optional: true
  
  validates :make, :model, :year, :price, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :kilometers, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  def self.vehicle_types
    {
      'Voiture': ['Berline', 'SUV', 'Coupé', 'Break', 'Monospace', 'Citadine', 'Cabriolet', 'Roadster', 'Pick-up', 'Limousine', 'Compacte', 'SUV Compact', 'SUV Coupé', 'Voiture de sport', 'Muscle Car', 'Hypercar', 'Grand Tourisme (GT)', 'Voiture électrique (EV)', 'Voiture hybride (HEV)', 'SUV Hybride/Électrique', 'Microcar/Kei Car', 'Crossover', 'Fourgonnette', 'Familiale', 'Sous-compacte', 'Voiture autonome', 'Voiture à hydrogène (FCV)', 'Hot Hatch', 'Utilitaire Sport de Luxe (Luxury SUV)', 'Voiture de collection'],
      'Moto': ['Moto de route', 'Sportive', 'Routière', 'Custom', 'Trail', 'Enduro', 'Cross', 'Scooter', 'Maxi-Scooter', 'Moto électrique', 'Trail routier', 'Sport-Touring', 'Café Racer', 'Bobber', 'Chopper', 'Supermotard', 'Trike', 'Side-car', 'Mobylette/Cyclomoteur', 'Dirt Bike'],
      'Bateau': ['Voilier monocoque', 'Catamaran', 'Trimaran', 'Yacht à voile', 'Yacht à moteur', 'Péniche', 'Bateau de pêche', 'Bateau de plaisance à moteur', 'Canot à moteur', 'Bateau pneumatique', 'Kayak', 'Canoë', 'Jet ski/Motomarine', 'Houseboat', 'Ferry', 'Remorqueur', 'Barge', 'Hydroptère', 'Hovercraft', 'Voilier habitable'],
      'Quad': ['Quad de loisir', 'Quad utilitaire', 'Quad sportif', 'Quad pour jeunes', 'Quad 4x4', 'Quad 2x4', 'Quad à suspension indépendante', 'Quad à essieu rigide', 'Quad à moteur monocylindre', 'Quad à moteur bicylindre', 'Quad électrique', 'Quad hybride', 'Quad à longue course de suspension', 'Quad de randonnée', 'Quad de boue', 'Quad side-by-side / UTV', 'Quad tout-terrain léger', 'Quad à direction assistée', 'Quad amphibie', 'Mini-Quad'],
      'Avion': ['Avion de ligne', 'Avion de transport de fret', 'Avion de tourisme', 'Avion d\'affaires', 'Avion de chasse', 'Bombardier', 'Avion de reconnaissance', 'Avion de transport militaire', 'Avion d\'entraînement', 'Hydravion', 'Amphibie', 'Avion à hélices', 'Avion à réaction', 'Avion à turbopropulseur', 'ULM', 'Planeur', 'Motoplaneur', 'Avion de voltige', 'Avion expérimental', 'Drone/UAV'],
      'Véhicule de compétition': ['Formule 1', 'IndyCar', 'Formule E', 'Rallye', 'GT3', 'GT4', 'Prototype d\'Endurance', 'Tourisme', 'Stock Car', 'Voiture de Drift', 'Voiture de Rallycross', 'Formule Régionale', 'Formule 4', 'Voiture de Course de Côte', 'Dragster', 'Karting', 'Buggy de Course Tout-Terrain', 'Trophy Truck', 'Voiture de Course sur Glace', 'Sprint Car'],
      'Camion': ['Camion benne basculante', 'Camion benne à ordures', 'Camion benne à gravats', 'Camion benne à céréales', 'Camion porteur', 'Camion semi-remorque', 'Camion citerne', 'Camion frigorifique', 'Camion plateau', 'Camion fourgon', 'Camion de déménagement', 'Camion de pompiers', 'Camion de dépannage', 'Camion de transport de voitures', 'Camion de transport de chevaux', 'Camion de transport de bateaux', 'Camion balayeuse', 'Camion d\'arrosage'],
      'Véhicule de chantier': ['Excavatrice', 'Chargeuse sur pneus', 'Bulldozer', 'Niveleuse', 'Compacteur', 'Grue mobile', 'Grue à tour', 'Chariot élévateur', 'Tractopelle', 'Foreuse', 'Finisseur', 'Pompe à béton', 'Bétonnière automotrice', 'Dumper', 'Décapeuse', 'Raboteuse', 'Fraiseuse', 'Trancheuse', 'Pilonneuse', 'Foreuse directionnelle'],
      'Buggy et Kart': ['Buggy de plage', 'Buggy tout-terrain', 'Buggy de dune', 'Buggy de course', 'Buggy de safari', 'Buggy amphibie', 'Buggy électrique', 'Kart à essence', 'Kart électrique', 'Kart de course', 'Superkart', 'Kart de location', 'Kart pour enfants', 'Kart à dérive', 'Kart tout-terrain', 'Kart à pédales'],
      'Autre': []
    }
  end
  
  def self.equipment_categories
    {
      'Sécurité': ['ABS', 'ESP', 'Airbags frontaux', 'Airbags latéraux', 'Airbags rideaux', 'Alarme', 'Verrouillage centralisé', 'Fixations ISOFIX', 'Détecteur de fatigue', 'Système d\'appel d\'urgence'],
      'Confort': ['Climatisation manuelle', 'Climatisation automatique', 'Climatisation bi-zone', 'Sellerie cuir', 'Sellerie tissu', 'Sièges chauffants', 'Sièges électriques', 'Sièges à mémoire', 'Régulateur de vitesse', 'Limiteur de vitesse', 'Direction assistée', 'Vitres électriques avant', 'Vitres électriques arrière', 'Rétroviseurs électriques', 'Rétroviseurs rabattables électriquement', 'Toit ouvrant', 'Toit panoramique', 'Détecteur de pluie', 'Allumage automatique des phares', 'Aide au stationnement avant', 'Aide au stationnement arrière', 'Caméra de recul'],
      'Multimédia': ['Système audio', 'Navigation GPS', 'Lecteur CD/DVD', 'Prise auxiliaire', 'Prise USB', 'Bluetooth', 'Écran tactile', 'Apple CarPlay', 'Android Auto', 'Commandes au volant', 'Système audio premium'],
      'Extérieur': ['Jantes alliage', 'Phares xénon', 'Phares LED', 'Feux antibrouillard', 'Attelage de remorque', 'Barres de toit', 'Toit ouvrant', 'Vitres teintées'],
      'Autre': ['Volant multifonctions', 'Ordinateur de bord', 'Tapis de sol d\'origine', 'Cache-bagages', 'Prise 12V', 'Système Stop & Start', 'Suspension sport', 'Mode de conduite']
    }
  end
  
  def self.specific_fields
    {
      'Voiture': ['doors', 'transmission', 'fuel_type', 'interior_material', 'interior_color'],
      'Moto': ['cylinder_capacity', 'engine_type', 'cooling_type', 'starter_type', 'license_type'],
      'Bateau': ['length', 'width', 'draft', 'hull_material', 'number_of_cabins', 'number_of_berths', 'engine_hours'],
      'Quad': ['cylinder_capacity', 'engine_type', 'cooling_type', 'transmission_type', 'drive_type', 'starter_type'],
      'Avion': ['number_of_seats', 'flight_hours', 'engine_hours', 'number_of_engines', 'ceiling', 'range'],
      'Véhicule de chantier': ['operating_hours', 'lifting_capacity', 'maximum_reach', 'additional_equipment', 'bucket_capacity'],
      'Camion': ['loading_capacity', 'towing_capacity', 'axles', 'sleeping_cab', 'emission_standard']
    }
  end
end
