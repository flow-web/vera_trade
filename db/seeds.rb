# frozen_string_literal: true

# Vera Trade — Production-ready seed data
# Idempotent: safe to run multiple times

puts "🌱 Seeding Vera Trade..."

# ── CATEGORIES ──────────────────────────────────────────────
# Only seed if empty (already created on first run)
if Category.count.zero?
  categories = {
    'Voitures' => { icon: 'car', subs: %w[Berline SUV Coupé Break Citadine Cabriolet Pick-up Compacte] },
    'Motos' => { icon: 'motorcycle', subs: [ 'Sportive', 'Routière', 'Custom', 'Trail', 'Scooter', 'Café Racer' ] },
    'Utilitaires' => { icon: 'truck', subs: [ 'Fourgon', 'Camionnette', 'Plateau', 'Benne', 'Frigorifique' ] },
    'Camping-cars' => { icon: 'caravan', subs: [ 'Profilé', 'Capucine', 'Intégral', 'Van aménagé', 'Fourgon aménagé' ] }
  }
  categories.each do |name, data|
    parent = Category.create!(name: name, icon: data[:icon], description: "#{name} d'occasion")
    data[:subs].each { |s| Category.create!(name: s, parent_id: parent.id, description: s) }
  end
  puts "  ✓ #{Category.count} catégories créées"
else
  puts "  ⏭ Catégories existantes (#{Category.count})"
end

# ── USERS ───────────────────────────────────────────────────
users_data = [
  { email: 'admin@veratrade.fr', first_name: 'Florian', last_name: 'Parisi', phone: '0601020304', role: 2 },
  { email: 'sophie.martin@gmail.com', first_name: 'Sophie', last_name: 'Martin', phone: '0611223344', role: 0 },
  { email: 'karim.benali@outlook.fr', first_name: 'Karim', last_name: 'Benali', phone: '0622334455', role: 0 },
  { email: 'pierre.durand@yahoo.fr', first_name: 'Pierre', last_name: 'Durand', phone: '0633445566', role: 0 },
  { email: 'marie.leclerc@gmail.com', first_name: 'Marie', last_name: 'Leclerc', phone: '0644556677', role: 0 },
  { email: 'lucas.petit@hotmail.com', first_name: 'Lucas', last_name: 'Petit', phone: '0655667788', role: 0 },
  { email: 'julie.moreau@gmail.com', first_name: 'Julie', last_name: 'Moreau', phone: '0666778899', role: 0 },
  { email: 'thomas.garcia@pro.fr', first_name: 'Thomas', last_name: 'Garcia', phone: '0677889900', role: 0 }
]

users = users_data.map do |data|
  User.find_or_create_by!(email: data[:email]) do |u|
    u.password = 'VeraTrade2026!'
    u.first_name = data[:first_name]
    u.last_name = data[:last_name]
    u.phone = data[:phone]
    u.role = data[:role]
    u.confirmed_at = Time.current
  end
end
puts "  ✓ #{users.size} utilisateurs (#{User.count} total)"

admin, sophie, karim, pierre, marie, lucas, julie, thomas = users

# ── VEHICLES & LISTINGS ────────────────────────────────────
cat_voitures = Category.find_by(name: 'Voitures') || Category.first
cat_motos = Category.find_by(name: 'Motos') || Category.first

vehicles_data = [
  # ── Voitures ──
  {
    vehicle: {
      make: 'Porsche', model: '911 Carrera S', year: 2021, price: 139_900, kilometers: 18_500,
      fuel_type: 'Essence', transmission: 'PDK', finition: 'Carrera S', doors: 2,
      exterior_color: 'Gris Craie', interior_material: 'Cuir', interior_color: 'Noir/Bordeaux',
      previous_owners: 1, has_service_history: true, non_smoker: true, location: 'Monaco',
      license_plate: 'GH-911-PS', vin: 'WP0AB2A91MS200001',
      fiscal_power: 30, co2_emissions: 228, average_consumption: 10.1,
      category: cat_voitures,
      safety_features: 'PASM, PTV Plus, Freins céramique PCCB',
      comfort_features: 'Sièges Sport adaptatifs 18 réglages, Chrono Package, Bose Surround',
      body_condition: 'État concours, zéro défaut carrosserie'
    },
    listing: { title: 'Porsche 911 (992) Carrera S PDK — 1ère main Monaco', user: sophie, status: 'active' }
  },
  {
    vehicle: {
      make: 'Mercedes-Benz', model: 'Classe G 63 AMG', year: 2022, price: 198_000, kilometers: 12_000,
      fuel_type: 'Essence', transmission: 'Automatique', finition: 'AMG', doors: 5,
      exterior_color: 'Noir Obsidienne', interior_material: 'Cuir Nappa', interior_color: 'Rouge Bengal',
      previous_owners: 1, has_service_history: true, non_smoker: true, location: 'Paris 16e',
      license_plate: 'AA-063-MG', vin: 'WDB4632721X300001',
      fiscal_power: 36, co2_emissions: 299, average_consumption: 13.1,
      category: cat_voitures,
      safety_features: 'Active Brake Assist, Blind Spot, 360° Camera',
      comfort_features: 'Burmester 3D, Massage seats, Night Package'
    },
    listing: { title: 'Mercedes G63 AMG — Intérieur Rouge Bengal, Full Options', user: karim, status: 'active' }
  },
  {
    vehicle: {
      make: 'BMW', model: 'M3 Competition', year: 2023, price: 89_900, kilometers: 8_200,
      fuel_type: 'Essence', transmission: 'Automatique', finition: 'Competition xDrive', doors: 4,
      exterior_color: 'Vert Isle of Man', interior_material: 'Cuir Merino', interior_color: 'Noir',
      previous_owners: 1, has_service_history: true, non_smoker: true, location: 'Lyon',
      license_plate: 'BM-340-CP', vin: 'WBS43AZ09P8B00001',
      fiscal_power: 24, co2_emissions: 234, average_consumption: 10.2,
      category: cat_voitures,
      safety_features: 'M Carbon Ceramic Brakes, M Drive Professional',
      comfort_features: 'Harman Kardon, Head-up Display, M Carbon bucket seats'
    },
    listing: { title: 'BMW M3 Competition xDrive — Vert Isle of Man, 8200km', user: pierre, status: 'active' }
  },
  {
    vehicle: {
      make: 'Audi', model: 'RS6 Avant', year: 2022, price: 142_500, kilometers: 22_000,
      fuel_type: 'Essence', transmission: 'Tiptronic', finition: 'RS6 Performance', doors: 5,
      exterior_color: 'Gris Nardo', interior_material: 'Cuir/Alcantara', interior_color: 'Noir',
      previous_owners: 1, has_service_history: true, non_smoker: true, location: 'Strasbourg',
      license_plate: 'RS-600-AD', vin: 'WUAZZZ4K4NN100001',
      fiscal_power: 32, co2_emissions: 268, average_consumption: 11.8,
      category: cat_voitures,
      safety_features: 'Freins céramique, Différentiel sport, Matrix LED',
      comfort_features: 'Bang & Olufsen Advanced, Suspension pneumatique, Toit panoramique'
    },
    listing: { title: 'Audi RS6 Avant Performance — Gris Nardo, B&O Advanced', user: thomas, status: 'active' }
  },
  {
    vehicle: {
      make: 'Alpine', model: 'A110 S', year: 2023, price: 72_900, kilometers: 5_400,
      fuel_type: 'Essence', transmission: 'EDC', finition: 'S', doors: 2,
      exterior_color: 'Bleu Alpine', interior_material: 'Cuir/Microfibre', interior_color: 'Noir/Bleu',
      previous_owners: 1, has_service_history: true, non_smoker: true, location: 'Dieppe',
      license_plate: 'AL-110-FR', vin: 'VFA6AGHS0K1200001',
      fiscal_power: 15, co2_emissions: 164, average_consumption: 7.2,
      category: cat_voitures,
      safety_features: 'ESP Sport, Brembo 4 pistons',
      comfort_features: 'Focal audio, Sièges Sabelt, Telemetrics'
    },
    listing: { title: 'Alpine A110 S — Bleu Alpine, Sabelt, 5400km comme neuve', user: marie, status: 'active' }
  },
  {
    vehicle: {
      make: 'Peugeot', model: '208 GT', year: 2023, price: 24_500, kilometers: 15_000,
      fuel_type: 'Essence', transmission: 'Automatique', finition: 'GT', doors: 5,
      exterior_color: 'Jaune Faro', interior_material: 'Alcantara', interior_color: 'Noir',
      previous_owners: 1, has_service_history: true, non_smoker: true, location: 'Bordeaux',
      license_plate: 'PE-208-GT', vin: 'VR3UHZKXZPT100001',
      fiscal_power: 6, co2_emissions: 118, average_consumption: 5.2,
      category: cat_voitures,
      safety_features: "Freinage automatique d'urgence, Alerte franchissement de ligne",
      comfort_features: 'i-Cockpit 3D, Caméra 180°, Chargeur induction'
    },
    listing: { title: 'Peugeot 208 GT — Jaune Faro, i-Cockpit 3D, garantie', user: lucas, status: 'active' }
  },
  {
    vehicle: {
      make: 'Tesla', model: 'Model 3 Performance', year: 2023, price: 42_900, kilometers: 20_000,
      fuel_type: 'Électrique', transmission: 'Automatique', finition: 'Performance', doors: 4,
      exterior_color: 'Blanc Nacré', interior_material: 'Vegan Leather', interior_color: 'Noir',
      previous_owners: 1, has_service_history: true, non_smoker: true, location: 'Toulouse',
      license_plate: 'TS-003-EV', vin: '5YJ3E1EC5PF500001',
      fiscal_power: 1, co2_emissions: 1, average_consumption: 0.2,
      category: cat_voitures,
      safety_features: 'Autopilot, Freinage régénératif, 8 caméras',
      comfort_features: 'Écran 15.4", Premium Connectivity, Toit vitré'
    },
    listing: { title: 'Tesla Model 3 Performance — Autopilot, 0-100 en 3.3s', user: julie, status: 'active' }
  },
  # Vendu
  {
    vehicle: {
      make: 'Volkswagen', model: 'Golf 8 R', year: 2022, price: 48_500, kilometers: 28_000,
      fuel_type: 'Essence', transmission: 'DSG', finition: 'R', doors: 5,
      exterior_color: 'Bleu Lapiz', interior_material: 'Cuir/Alcantara', interior_color: 'Noir/Bleu',
      previous_owners: 2, has_service_history: true, non_smoker: true, location: 'Nantes',
      license_plate: 'VW-800-RR', vin: 'WVWZZZ1KZPW100001',
      fiscal_power: 14, co2_emissions: 168, average_consumption: 7.4,
      category: cat_voitures,
      safety_features: 'R-Performance Torque Vectoring, DCC adaptatif',
      comfort_features: 'Harman Kardon, Digital Cockpit Pro'
    },
    listing: { title: 'VW Golf 8 R DSG — Vendue en 48h !', user: sophie, status: 'sold', buyer: lucas }
  },
  # ── Motos ──
  {
    vehicle: {
      make: 'Ducati', model: 'Panigale V4 S', year: 2023, price: 32_900, kilometers: 3_200,
      fuel_type: 'Essence', transmission: 'Manuelle',
      exterior_color: 'Rouge Ducati', previous_owners: 1, has_service_history: true,
      location: 'Nice', license_plate: 'DC-400-VS',
      category: cat_motos,
      safety_features: 'Cornering ABS EVO, Wheelie Control, Slide Control',
      comfort_features: 'Öhlins Smart EC 2.0, Écran TFT 6.9"'
    },
    listing: { title: 'Ducati Panigale V4 S — 3200km, full Öhlins', user: karim, status: 'active' }
  },
  {
    vehicle: {
      make: 'Triumph', model: 'Speed Triple 1200 RS', year: 2022, price: 16_900, kilometers: 8_500,
      fuel_type: 'Essence', transmission: 'Manuelle',
      exterior_color: 'Storm Grey', previous_owners: 1, has_service_history: true,
      location: 'Montpellier', license_plate: 'TR-120-RS', vin: 'SMTD40HL0NT700001',
      category: cat_motos,
      safety_features: 'IMU 6 axes, Cornering ABS, Traction Control multi-mode',
      comfort_features: 'Quickshifter bidirectionnel, TFT 5"'
    },
    listing: { title: 'Triumph Speed Triple 1200 RS — Échappement Arrow', user: pierre, status: 'active' }
  }
]

created_count = 0
vehicles_data.each do |data|
  vd = data[:vehicle].except(:category)
  cat = data[:vehicle][:category]

  # Skip if license_plate already exists
  next if vd[:license_plate] && Vehicle.exists?(license_plate: vd[:license_plate].upcase.gsub(/[^A-Z0-9]/, ''))
  # Skip if VIN already exists
  next if vd[:vin] && Vehicle.exists?(vin: vd[:vin].upcase.gsub(/[^A-Z0-9]/, ''))

  vehicle = Vehicle.create!(vd.merge(category_id: cat&.id))

  ld = data[:listing]
  Listing.create!(
    title: ld[:title],
    description: "#{ld[:title]}. Véhicule en excellent état, visible sur rendez-vous.",
    user: ld[:user],
    vehicle: vehicle,
    status: ld[:status] || 'active',
    buyer_id: ld[:buyer]&.id
  )
  created_count += 1
end
puts "  ✓ #{created_count} annonces créées (#{Listing.count} total)"

# ── CONVERSATIONS & MESSAGES ───────────────────────────────
convos = [
  { from: lucas, to: sophie, messages: [
    { from: lucas, text: "Bonjour, la Porsche 911 est-elle encore disponible ?" },
    { from: sophie, text: "Oui tout à fait ! Elle est visible sur rendez-vous à Monaco." },
    { from: lucas, text: "Super. Quel serait votre meilleur prix pour un achat comptant ?" },
    { from: sophie, text: "Pour un achat cash je peux descendre à 135 000€. Elle est vraiment impeccable." },
    { from: lucas, text: "Je réfléchis et je reviens vers vous rapidement. Merci !" }
  ] },
  { from: marie, to: karim, messages: [
    { from: marie, text: "Bonjour, la Panigale V4 S m'intéresse beaucoup. Historique d'entretien complet ?" },
    { from: karim, text: "Oui, entretien exclusivement chez Ducati Nice. Carnet tamponné. Je peux envoyer les factures." },
    { from: marie, text: "Parfait. Possible d'organiser un essai ce week-end ?" },
    { from: karim, text: "Samedi matin ça vous irait ? Je suis dispo à partir de 10h." }
  ] },
  { from: thomas, to: julie, messages: [
    { from: thomas, text: "La Tesla Model 3 Performance, vous avez le Full Self-Driving ?" },
    { from: julie, text: "Non c'est l'Autopilot de base. Le FSD n'est pas transférable de toute façon." },
    { from: thomas, text: "OK merci pour la précision. Autonomie réelle en hiver ?" },
    { from: julie, text: "Comptez 350-380km sur autoroute en hiver, 450+ en ville/mixte." }
  ] }
]

convos_created = 0
convos.each do |cd|
  convo = Conversation.find_or_create_by!(user: cd[:from], other_user: cd[:to])
  next if Message.where(sender_id: cd[:from].id, recipient_id: cd[:to].id).exists?

  cd[:messages].each_with_index do |msg, i|
    Message.create!(
      sender_id: msg[:from].id,
      recipient_id: (msg[:from] == cd[:from] ? cd[:to] : cd[:from]).id,
      content: msg[:text],
      read: i < cd[:messages].size - 1,
      created_at: (cd[:messages].size - i).hours.ago
    )
  end
  convos_created += 1
end
puts "  ✓ #{convos_created} conversations (#{Message.count} messages)"

puts "✅ Seed terminé — #{User.count} users, #{Listing.count} annonces, #{Message.count} messages"

# -----------------------------------------------------------------------------
# M8 — Annonce éditoriale complète avec wizard data (Rust Map + provenance +
# originality). Utilise la première annonce disponible du premier vendeur.
# -----------------------------------------------------------------------------
example_listing = Listing.where(status: "active").includes(:vehicle).order(:id).first
if example_listing
  rm = example_listing.rust_map || example_listing.create_rust_map!(silhouette_variant: "sedan")
  if rm.zones.empty?
    [
      { x_pct: 42.5, y_pct: 68.0, status: "surface", label: "Plancher arrière droit" },
      { x_pct: 55.1, y_pct: 71.2, status: "ok",      label: "Longeron droit" },
      { x_pct: 68.4, y_pct: 72.9, status: "deep",    label: "Bas de caisse arrière" }
    ].each_with_index { |z, i| rm.zones.create!(z.merge(position: i)) }
    rm.recompute_score!
  end

  unless example_listing.originality_score
    example_listing.create_originality_score!(
      overall_score: 94,
      matching_numbers: true,
      original_interior: true,
      original_paint_pct: 85,
      notes: "Numéros d'origine, peinture 85% d'origine, intérieur 100% matching"
    )
  end

  if example_listing.provenance_events.empty?
    [
      { event_year: example_listing.vehicle.year,      event_type: "purchase",    label: "Livraison neuve" },
      { event_year: example_listing.vehicle.year + 23, event_type: "restoration", label: "Restauration cosmétique + peinture ailes" },
      { event_year: 2025,                              event_type: "service",     label: "Révision complète + pneus neufs" }
    ].each_with_index { |e, i| example_listing.provenance_events.create!(e.merge(position: i)) }
  end

  puts "  ✓ M8 wizard data attaché à listing ##{example_listing.id} (Rust Map score: #{rm.reload.transparency_score}, originalité: #{example_listing.originality_score.overall_score})"
end
