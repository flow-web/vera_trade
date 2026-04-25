# frozen_string_literal: true

# Vera Trade — Collector Car Auction Platform
# Idempotent seed: safe to run multiple times (find_or_create_by, no deletes)
# Wrapped in transaction for speed

puts "Seeding Vera Trade..."

ActiveRecord::Base.transaction do
  # ── CATEGORIES ────────────────────────────────────────────────
  if Category.count.zero?
    categories = {
      "Voitures" => { icon: "car", subs: %w[Berline Coupe Cabriolet Break Citadine SUV] },
      "Motos" => { icon: "motorcycle", subs: ["Sportive", "Cafe Racer", "Routiere", "Custom", "Trail"] },
      "Utilitaires" => { icon: "truck", subs: %w[Fourgon Camionnette Plateau Benne] },
      "Camping-cars" => { icon: "caravan", subs: ["Fourgon amenage", "Van amenage", "Profile", "Integral"] }
    }
    categories.each do |name, data|
      parent = Category.create!(name: name, icon: data[:icon], description: "#{name} d'occasion")
      data[:subs].each { |s| Category.create!(name: s, parent_id: parent.id, description: s) }
    end
    puts "  #{Category.count} categories created"
  else
    puts "  Categories already present (#{Category.count})"
  end

  cat_voitures = Category.find_by(name: "Voitures") || Category.first

  # ── ADMIN ─────────────────────────────────────────────────────
  admin = User.find_or_create_by!(email: "admin@veratrade.fr") do |u|
    u.password = "AdminVera2026!"
    u.first_name = "Florian"
    u.last_name = "Parisi"
    u.phone = "0601020304"
    u.role = 1
    u.kyc_status = "verified"
    u.confirmed_at = Time.current
    u.terms_accepted = true
  end
  puts "  Admin: #{admin.email} (role=#{admin.role})"

  # ── SELLERS ───────────────────────────────────────────────────
  sellers_data = [
    { email: "jean-marc.duval@gmail.com", first_name: "Jean-Marc", last_name: "Duval",
      phone: "0612345678", role: 0, kyc_status: "verified" },
    { email: "sophie.renault@outlook.fr", first_name: "Sophie", last_name: "Renault",
      phone: "0623456789", role: 0, kyc_status: "verified" },
    { email: "philippe.moreau@yahoo.fr", first_name: "Philippe", last_name: "Moreau",
      phone: "0634567890", role: 0, kyc_status: "verified" }
  ]

  sellers = sellers_data.map do |data|
    User.find_or_create_by!(email: data[:email]) do |u|
      u.password = "VeraTrade2026!"
      u.first_name = data[:first_name]
      u.last_name = data[:last_name]
      u.phone = data[:phone]
      u.role = data[:role]
      u.kyc_status = data[:kyc_status]
      u.confirmed_at = Time.current
      u.terms_accepted = true
    end
  end
  jean_marc, sophie, philippe = sellers
  puts "  #{sellers.size} sellers created/found"

  # ── BIDDER ACCOUNTS ───────────────────────────────────────────
  bidders_data = [
    { email: "lucas.petit@gmail.com", first_name: "Lucas", last_name: "Petit",
      phone: "0645678901", role: 0, kyc_status: "verified" },
    { email: "marie.leclerc@hotmail.com", first_name: "Marie", last_name: "Leclerc",
      phone: "0656789012", role: 0, kyc_status: "verified" },
    { email: "karim.benali@outlook.fr", first_name: "Karim", last_name: "Benali",
      phone: "0667890123", role: 0, kyc_status: "verified" }
  ]

  bidders = bidders_data.map do |data|
    User.find_or_create_by!(email: data[:email]) do |u|
      u.password = "VeraTrade2026!"
      u.first_name = data[:first_name]
      u.last_name = data[:last_name]
      u.phone = data[:phone]
      u.role = data[:role]
      u.kyc_status = data[:kyc_status]
      u.confirmed_at = Time.current
      u.terms_accepted = true
    end
  end
  lucas, marie, karim = bidders
  puts "  #{bidders.size} bidders created/found"

  # ── COLLECTOR CAR LISTINGS ────────────────────────────────────
  #
  # Each entry: vehicle attributes + listing metadata.
  # Editorial French descriptions written in the "Cinematic Archivist" tone.
  #
  listings_data = [
    # ── 1. Lancia Delta HF Integrale Evoluzione ──
    {
      vehicle: {
        make: "Lancia", model: "Delta HF Integrale Evoluzione", year: 1992,
        price: 78_500, kilometers: 67_400,
        fuel_type: "Essence", transmission: "Manuelle", doors: 5,
        exterior_color: "Rosso Monza", interior_material: "Alcantara", interior_color: "Noir",
        previous_owners: 3, has_service_history: true, non_smoker: true,
        location: "Modane (73)",
        license_plate: "DL-192-HF", vin: "ZLA83100000580012",
        fiscal_power: 12, co2_emissions: 245, average_consumption: 11.8,
        category_id: cat_voitures&.id,
        safety_features: "ABS Bosch, Turbo Garrett T3, Transmission integrale permanente",
        comfort_features: "Sellerie Alcantara Recaro, Compteur Veglia Borletti 260 km/h",
        body_condition: "Ailes elargies d'origine, peinture refaite dans le ton Rosso Monza en 2019. Zero corrosion visible."
      },
      listing: {
        title: "Lancia Delta HF Integrale Evo — Rosso Monza, matching numbers",
        description: "Six titres mondiaux des rallyes coulent dans ses veines. Cette Evoluzione " \
                     "sort d'un garage chauffe de Savoie ou elle a passe ses quinze dernieres " \
                     "annees entre les mains d'un ingenieur Fiat a la retraite. Carnet tamponne " \
                     "chez Lancia Turin jusqu'en 2008, puis suivi rigoureux en independant. " \
                     "Turbo refait a 58 000 km, embrayage Sachs neuf a 62 000. Le differentiel " \
                     "Torsen arriere chante encore comme au premier jour. Numeros concordants, " \
                     "interieur 100% d'origine. Une piece de musee qui demande a rouler.",
        user: jean_marc, status: "active", published_at: 3.days.ago
      }
    },

    # ── 2. Porsche 964 Carrera 4 ──
    {
      vehicle: {
        make: "Porsche", model: "911 Carrera 4 (964)", year: 1990,
        price: 92_000, kilometers: 124_800,
        fuel_type: "Essence", transmission: "Manuelle", doors: 2,
        exterior_color: "Grand Prix Weiss", interior_material: "Cuir", interior_color: "Bleu Marine",
        previous_owners: 4, has_service_history: true, non_smoker: true,
        location: "Strasbourg (67)",
        license_plate: "PR-964-CA", vin: "WP0ZZZ96ZLS400123",
        fiscal_power: 18, co2_emissions: 280, average_consumption: 12.5,
        category_id: cat_voitures&.id,
        safety_features: "ABS, Transmission integrale, Airbag conducteur",
        comfort_features: "Climatisation d'epoque, Autoradio Blaupunkt Bremen, Toit ouvrant electrique",
        body_condition: "Blanc Grand Prix sans raccord, bas de caisse sains. Optiques H4 d'origine."
      },
      listing: {
        title: "Porsche 964 Carrera 4 — Blanc Grand Prix, interieur bleu, toit ouvrant",
        description: "La derniere 911 refroidie par air avec la transmission integrale " \
                     "derivee de la 959. Celle-ci porte sa robe blanche d'origine sur un " \
                     "interieur bleu marine rarement croise a cette epoque. Quatre " \
                     "proprietaires documentes, tous en Alsace. Vidange moteur et boite " \
                     "tous les 10 000 km sans exception. Le flat-six de 3,6 litres " \
                     "developpe 250 chevaux avec une linearite que les turbos n'atteindront " \
                     "jamais. CT OK sans remarque. Visible sur rendez-vous a Strasbourg.",
        user: sophie, status: "active", published_at: 5.days.ago
      }
    },

    # ── 3. Alpine A110 1600S ──
    {
      vehicle: {
        make: "Alpine", model: "A110 1600S", year: 1972,
        price: 135_000, kilometers: 41_200,
        fuel_type: "Essence", transmission: "Manuelle", doors: 2,
        exterior_color: "Bleu Metalise", interior_material: "Skai", interior_color: "Noir",
        previous_owners: 2, has_service_history: true, non_smoker: true,
        location: "Dieppe (76)",
        license_plate: "AL-110-SS", vin: "VFA110S600017842A",
        fiscal_power: 9, co2_emissions: 195, average_consumption: 9.8,
        category_id: cat_voitures&.id,
        safety_features: "Freins a disque avant, Chassis tubulaire poutre centrale",
        comfort_features: "Compteur Jaeger 240 km/h, Volant Moto-Lita cuir",
        body_condition: "Polyester d'origine sans fissure. Restauration complete en 2016 par l'Atelier Alpine de Dieppe."
      },
      listing: {
        title: "Alpine A110 1600S Berlinette — Bleu Metalise, restauration Dieppe",
        description: "La Berlinette qui a fait trembler Porsche au Monte-Carlo 1973. " \
                     "Cet exemplaire est passe entre les mains de l'Atelier Alpine " \
                     "historique de Dieppe pour une restauration dans les regles : " \
                     "moteur 1600S reconditionne, carburateurs Weber 45 DCOE neufs, " \
                     "trains roulants revises. Le chassis tubulaire a ete controle par " \
                     "radiographie — aucune fissure. La coque polyester a ete poncee " \
                     "et relaquee dans le bleu metalise d'origine. 680 kg, propulsion, " \
                     "moteur en porte-a-faux arriere : la conduite est un acte de foi.",
        user: philippe, status: "active", published_at: 2.days.ago
      }
    },

    # ── 4. BMW E30 M3 ──
    {
      vehicle: {
        make: "BMW", model: "M3 (E30)", year: 1989,
        price: 89_000, kilometers: 98_600,
        fuel_type: "Essence", transmission: "Manuelle", doors: 2,
        exterior_color: "Noir Diamant", interior_material: "Cuir", interior_color: "Gris Anthracite",
        previous_owners: 3, has_service_history: true, non_smoker: true,
        location: "Lyon (69)",
        license_plate: "BM-300-ME", vin: "WBSAK0300K2195478",
        fiscal_power: 14, co2_emissions: 258, average_consumption: 11.2,
        category_id: cat_voitures&.id,
        safety_features: "ABS, Differentiel autobloquant 25%, Arceau Heigo demi-cage",
        comfort_features: "Sieges sport Recaro, Volant M-Technic II, Climatisation",
        body_condition: "Noir Diamant d'origine, ailes elargies saines. Petite retouche aile ARD en 2020."
      },
      listing: {
        title: "BMW E30 M3 — Noir Diamant, S14 d'origine, carnet complet",
        description: "Le S14 quatre cylindres de 2,3 litres hurle jusqu'a 7 250 tours " \
                     "avec l'appetit d'un moteur de course homologue pour la route. Cet " \
                     "exemplaire conserve son bloc d'origine (numeros concordants), " \
                     "entretenu exclusivement par le reseau BMW Motorsport puis par " \
                     "un specialiste reconnu a Lyon. Embrayage Sachs renforce a 82 000 km, " \
                     "distribution refaite a 90 000. L'arceau Heigo est homologue route. " \
                     "Pas un jouet de salon : cette M3 roule regulierement et ca se sent.",
        user: jean_marc, status: "active", published_at: 7.days.ago
      }
    },

    # ── 5. Alfa Romeo GTV6 2.5 ──
    {
      vehicle: {
        make: "Alfa Romeo", model: "GTV6 2.5", year: 1984,
        price: 38_500, kilometers: 112_000,
        fuel_type: "Essence", transmission: "Manuelle", doors: 2,
        exterior_color: "Verde Metallizzato", interior_material: "Cuir", interior_color: "Beige",
        previous_owners: 5, has_service_history: true, non_smoker: false,
        location: "Aix-en-Provence (13)",
        license_plate: "AR-846-GV", vin: "ZAR11600000412567",
        fiscal_power: 12, co2_emissions: 238, average_consumption: 11.5,
        category_id: cat_voitures&.id,
        safety_features: "Freins a disque aux 4 roues, Differentiel autobloquant",
        comfort_features: "V6 Busso 2.5L, Boite transaxle de Tomaso, Tableau de bord Bertone",
        body_condition: "Reprise de corrosion bas de porte droit en 2021. Peinture verte metalise refaite 60% carrosserie."
      },
      listing: {
        title: "Alfa Romeo GTV6 2.5 Bertone — V6 Busso, vert metalise",
        description: "Le V6 Busso est peut-etre le plus beau son jamais sorti d'un " \
                     "six cylindres. Celui-ci chante a merveille grace a une revision " \
                     "complete en 2023 : courroies, tendeurs, pompe a eau, durites " \
                     "silicone. La boite transaxle signee de Tomaso confere un equilibre " \
                     "50/50 rare dans cette gamme de prix. Carrosserie Bertone au dessin " \
                     "toujours incisif. Le cuir beige a vecu mais reste digne. CT OK, " \
                     "quelques remarques mineures corrosion superficielle notees et traitees. " \
                     "Un collector accessible qui se bonifie chaque annee.",
        user: sophie, status: "active", published_at: 10.days.ago
      }
    },

    # ── 6. Peugeot 205 GTI 1.9 ──
    {
      vehicle: {
        make: "Peugeot", model: "205 GTI 1.9", year: 1990,
        price: 32_000, kilometers: 145_000,
        fuel_type: "Essence", transmission: "Manuelle", doors: 3,
        exterior_color: "Rouge Vallelunga", interior_material: "Tissu", interior_color: "Gris Quartet",
        previous_owners: 4, has_service_history: true, non_smoker: true,
        location: "Sochaux (25)",
        license_plate: "PG-205-GT", vin: "VF320CD6224567891",
        fiscal_power: 8, co2_emissions: 198, average_consumption: 8.5,
        category_id: cat_voitures&.id,
        safety_features: "Freins a disque ventiles avant, Direction assistee",
        comfort_features: "Compteur a 10 000 tours, Volant cuir a 3 branches, Vitres electriques",
        body_condition: "Rouge Vallelunga eclatant, repeinte complete en 2022. Passages de roue sains, longerons OK."
      },
      listing: {
        title: "Peugeot 205 GTI 1.9 — Rouge Vallelunga, sellerie Quartet, phase 2",
        description: "La 205 GTI n'a pas besoin de presentation. Celle-ci est une 1.9 " \
                     "phase 2 de 130 chevaux avec la sellerie Quartet grise que les " \
                     "puristes recherchent. Moteur XU9JA sain, sans consommation d'huile, " \
                     "demarrage au quart de tour. Embrayage refait a 130 000 km, " \
                     "amortisseurs Bilstein B4 neufs. Pas de bricolage : tout est " \
                     "d'origine ou remplace par des pieces equivalentes. Le rouge " \
                     "Vallelunga a ete refait dans les regles en carrosserie — aucun " \
                     "masticage. Elle sort de Sochaux et y reste : visible a 10 minutes " \
                     "de l'usine historique.",
        user: philippe, status: "active", published_at: 1.day.ago
      }
    },

    # ── 7. Mercedes-Benz W124 300CE ──
    {
      vehicle: {
        make: "Mercedes-Benz", model: "300 CE (W124)", year: 1991,
        price: 28_000, kilometers: 178_000,
        fuel_type: "Essence", transmission: "Automatique", doors: 2,
        exterior_color: "Bleu-Noir Metalise", interior_material: "Cuir", interior_color: "Palomino",
        previous_owners: 2, has_service_history: true, non_smoker: true,
        location: "Paris 16e",
        license_plate: "MB-300-CE", vin: "WDB1240512B456789",
        fiscal_power: 13, co2_emissions: 265, average_consumption: 12.0,
        category_id: cat_voitures&.id,
        safety_features: "ABS, Airbag conducteur, Pretensionneurs de ceinture",
        comfort_features: "Climatisation automatique, Toit ouvrant electrique, Bose 10 HP (retrofitte)",
        body_condition: "Bleu-Noir sans defaut majeur. Chrome impeccable. Aucune trace de rouille — c'est une W124."
      },
      listing: {
        title: "Mercedes 300 CE Coupe W124 — Cuir Palomino, 2 proprietaires",
        description: "La W124 est la derniere Mercedes construite sans compromis " \
                     "budgetaire. Ce coupe 300 CE a passe toute sa vie entre deux " \
                     "proprietaires parisiens — un diplomate puis un medecin — avec " \
                     "un entretien exclusivement chez Mercedes Etoile Champs-Elysees. " \
                     "Le six cylindres en ligne M103 est inusable si entretenu, et " \
                     "celui-ci l'a ete. Distribution a chaine, pas de courroie a craindre. " \
                     "L'interieur Palomino (beige miel) sans craquelure est un miracle " \
                     "a ce kilometrage. Grand tourisme a l'ancienne.",
        user: jean_marc, status: "pending", published_at: nil
      }
    },

    # ── 8. Citroen CX GTI Turbo 2 ──
    {
      vehicle: {
        make: "Citroen", model: "CX GTI Turbo 2", year: 1987,
        price: 24_500, kilometers: 156_000,
        fuel_type: "Essence", transmission: "Manuelle", doors: 5,
        exterior_color: "Gris Futura", interior_material: "Velours", interior_color: "Gris",
        previous_owners: 6, has_service_history: false, non_smoker: false,
        location: "Aulnay-sous-Bois (93)",
        license_plate: "CX87GT2", vin: "VF7MAXR0000RH7892",
        fiscal_power: 10, co2_emissions: 230, average_consumption: 10.8,
        category_id: cat_voitures&.id,
        safety_features: "Direction DIRAVI, Suspension hydropneumatique, Freins haute pression",
        comfort_features: "Tableau de bord satellite lunaire, Compteur a rouleaux, Turbo Garrett",
        body_condition: "Peinture fatiguee mais sans corrosion perforante. Quelques eclats sur le capot. Honnete."
      },
      listing: {
        title: "Citroen CX GTI Turbo 2 — DIRAVI, hydropneumatique, ovni francais",
        description: "La CX Turbo 2 est un vaisseau spatial a quatre roues. La " \
                     "suspension hydropneumatique avale tout, la direction DIRAVI " \
                     "deroute puis fascine, et le turbo Garrett pousse les 168 chevaux " \
                     "avec un lag delicieusement retro. Six proprietaires, carnet " \
                     "incomplet mais factures presentes depuis 2010 chez un specialiste " \
                     "CX d'Aulnay. Spheres neuves 2024, LHM vidange, freins revises. " \
                     "La peinture Gris Futura est fatiguee mais l'ame est intacte. " \
                     "Pour initiees seulement.",
        user: sophie, status: "active", published_at: 14.days.ago
      }
    },

    # ── 9. Renault 5 Turbo 2 (SOLD) ──
    {
      vehicle: {
        make: "Renault", model: "5 Turbo 2", year: 1985,
        price: 115_000, kilometers: 52_300,
        fuel_type: "Essence", transmission: "Manuelle", doors: 3,
        exterior_color: "Bleu Olympe", interior_material: "Tissu", interior_color: "Bleu/Noir",
        previous_owners: 3, has_service_history: true, non_smoker: true,
        location: "Viry-Chatillon (91)",
        license_plate: "R5T2BLU", vin: "VF1822000F0345678",
        fiscal_power: 9, co2_emissions: 220, average_consumption: 10.5,
        category_id: cat_voitures&.id,
        safety_features: "Moteur central arriere, Chassis tubulaire, Freins ventiles",
        comfort_features: "Compteur Veglia Borletti, Volant Renault Sport 3 branches",
        body_condition: "Etat collection. Polyester impeccable, aucun eclat."
      },
      listing: {
        title: "Renault 5 Turbo 2 — Bleu Olympe, 52 000 km, etat collection",
        description: "Moteur central, propulsion, turbo : la R5 Turbo est la plus " \
                     "folle des francaises de serie. Cette Turbo 2 (coque polyester, " \
                     "production plus accessible que la Turbo 1 tout-alu) n'a couvert " \
                     "que 52 300 km depuis 1985. Troisieme proprietaire, toujours " \
                     "garages a l'abri. Le turbo a ete refait a 45 000 km par Alpine " \
                     "Renault Dieppe. Embrayage neuf. L'exemplaire parfait pour entrer " \
                     "dans le cercle ferme des Groupe B routieres.",
        user: philippe, status: "sold", buyer: lucas, published_at: 30.days.ago
      }
    },

    # ── 10. Porsche 944 Turbo (auction piece) ──
    {
      vehicle: {
        make: "Porsche", model: "944 Turbo", year: 1986,
        price: 45_000, kilometers: 87_500,
        fuel_type: "Essence", transmission: "Manuelle", doors: 2,
        exterior_color: "Guards Red", interior_material: "Cuir", interior_color: "Noir",
        previous_owners: 3, has_service_history: true, non_smoker: true,
        location: "Mulhouse (68)",
        license_plate: "P944TRB", vin: "WP0AA0956GN450012",
        fiscal_power: 14, co2_emissions: 255, average_consumption: 11.0,
        category_id: cat_voitures&.id,
        safety_features: "ABS, Freins ventiles 4 pistons, Differentiel autobloquant",
        comfort_features: "Climatisation, Sieges sport electriques, Toit ouvrant",
        body_condition: "Guards Red sans raccord. Bas de caisse traites anti-corrosion annuellement."
      },
      listing: {
        title: "Porsche 944 Turbo — Guards Red, 87 500 km, turbo d'epoque",
        description: "La 944 Turbo est la Porsche intelligente des annees 80 : " \
                     "moteur avant, propulsion, equilibre parfait, turbo sobre. " \
                     "Cet exemplaire Mulhousien porte encore sa peinture Guards Red " \
                     "d'origine — une prouesse a 38 ans. Le 2.5 turbo de 220 chevaux " \
                     "demarre sans hesitation, la boite Getrag passe sans accrocher. " \
                     "CT en cours de validite, derniere revision majeure a 82 000 km " \
                     "(courroie, pompe a eau, durites turbo). Le marche 944 Turbo " \
                     "s'envole — celle-ci est prete a partir.",
        user: jean_marc, status: "active", published_at: 4.days.ago
      }
    }
  ]

  created_count = 0
  listing_records = {}

  listings_data.each_with_index do |data, idx|
    vd = data[:vehicle]
    ld = data[:listing]

    # Idempotency: skip if VIN or license_plate already exists
    normalized_plate = vd[:license_plate]&.upcase&.gsub(/[^A-Z0-9]/, "")
    normalized_vin = vd[:vin]&.upcase

    next if normalized_plate && Vehicle.exists?(license_plate: normalized_plate)
    next if normalized_vin && Vehicle.exists?(vin: normalized_vin)

    vehicle = Vehicle.create!(vd)

    listing = Listing.create!(
      title: ld[:title],
      description: ld[:description],
      user: ld[:user],
      vehicle: vehicle,
      status: ld[:status] || "active",
      buyer_id: ld[:buyer]&.id,
      published_at: ld[:published_at]
    )

    listing_records[idx] = listing
    created_count += 1
  end
  puts "  #{created_count} listings created (#{Listing.count} total)"

  # ── WIZARD DATA (Rust Map + Originality + Provenance) ─────────
  # Attach M8 wizard data to the first 3 active listings for demo richness.

  active_listings = Listing.where(status: "active").includes(:vehicle).order(:id).limit(3)
  active_listings.each do |listing|
    # Rust Map
    rm = listing.rust_map || listing.create_rust_map!(
      silhouette_variant: listing.vehicle.doors.to_i > 3 ? "sedan" : "coupe"
    )
    if rm.zones.empty?
      zones = [
        { x_pct: 15.0, y_pct: 82.0, status: "ok", label: "Longeron avant gauche" },
        { x_pct: 42.5, y_pct: 85.0, status: "surface", label: "Bas de caisse gauche" },
        { x_pct: 78.0, y_pct: 80.0, status: "ok", label: "Passage de roue arriere droit" }
      ]
      zones.each_with_index { |z, i| rm.zones.create!(z.merge(position: i)) }
      rm.recompute_score! if rm.respond_to?(:recompute_score!)
    end

    # Originality Score
    unless listing.originality_score
      listing.create_originality_score!(
        overall_score: rand(85..98),
        matching_numbers: true,
        original_interior: [true, true, false].sample,
        original_paint_pct: rand(60..100),
        notes: "Numeros concordants verifies sur plaque constructeur et moteur."
      )
    end

    # Provenance Events
    if listing.provenance_events.empty?
      year = listing.vehicle.year
      [
        { event_year: year, event_type: "purchase", label: "Premiere immatriculation" },
        { event_year: year + rand(10..20), event_type: "service", label: "Revision majeure (distribution, freins)" },
        { event_year: [2022, 2023, 2024].sample, event_type: "restoration", label: "Restauration cosmetique et traitement anti-corrosion" },
        { event_year: 2025, event_type: "service", label: "Controle technique OK, revision complete" }
      ].each_with_index { |e, i| listing.provenance_events.create!(e.merge(position: i)) }
    end
  end
  puts "  Wizard data (Rust Map + Originality + Provenance) attached to #{active_listings.size} listings"

  # ── AUCTIONS ──────────────────────────────────────────────────
  # Create auctions on 3 specific listings (by title match for idempotency).

  auction_configs = [
    {
      title_match: "Lancia Delta",
      starting_price: 55_000, reserve_price: 72_000,
      starts_at: 2.days.ago, duration_days: 7,
      bids: [
        { bidder: lucas, amount: 55_000 },
        { bidder: marie, amount: 56_000 },
        { bidder: karim, amount: 58_000 },
        { bidder: lucas, amount: 60_000 },
        { bidder: marie, amount: 62_500 }
      ]
    },
    {
      title_match: "Alpine A110 1600S",
      starting_price: 90_000, reserve_price: 125_000,
      starts_at: 1.day.ago, duration_days: 7,
      bids: [
        { bidder: karim, amount: 90_000 },
        { bidder: lucas, amount: 92_000 },
        { bidder: karim, amount: 95_000 }
      ]
    },
    {
      title_match: "Porsche 944 Turbo",
      starting_price: 30_000, reserve_price: 40_000,
      starts_at: 12.hours.ago, duration_days: 7,
      bids: [
        { bidder: marie, amount: 30_000 },
        { bidder: karim, amount: 31_000 }
      ]
    }
  ]

  auctions_created = 0
  auction_configs.each do |ac|
    listing = Listing.where(status: "active").where("title LIKE ?", "%#{ac[:title_match]}%").first
    next unless listing
    next if listing.auction.present?

    starts = ac[:starts_at]
    auction = Auction.create!(
      listing: listing,
      starting_price: ac[:starting_price],
      reserve_price: ac[:reserve_price],
      current_price: ac[:bids].last[:amount],
      status: "active",
      duration_days: ac[:duration_days],
      starts_at: starts,
      ends_at: starts + ac[:duration_days].days,
      bids_count: ac[:bids].size
    )

    ac[:bids].each_with_index do |bd, i|
      Bid.create!(
        auction: auction,
        bidder: bd[:bidder],
        amount: bd[:amount],
        created_at: starts + (i + 1).hours
      )
    end

    auctions_created += 1
  end
  puts "  #{auctions_created} auctions with bids created"

  # ── CONVERSATIONS ─────────────────────────────────────────────
  # A few realistic buyer-seller exchanges about the listings.

  lancia_listing = Listing.where("title LIKE ?", "%Lancia Delta%").first
  alpine_listing = Listing.where("title LIKE ?", "%Alpine A110%").first

  convos_data = []

  if lancia_listing
    convos_data << {
      listing: lancia_listing, from: lucas, to: lancia_listing.user,
      messages: [
        { from: :buyer, text: "Bonjour, la Delta Integrale m'interesse beaucoup. Le turbo a ete refait chez quel specialiste ?" },
        { from: :seller, text: "Bonjour, merci pour votre interet. Le turbo a ete reconditionne par TurboTechnik a Turin, specialiste Garrett agrees Lancia." },
        { from: :buyer, text: "Excellent. Est-ce que vous accepteriez une contre-expertise par un specialiste de mon choix avant enchere ?" },
        { from: :seller, text: "Bien sur. Je peux mettre le vehicule a disposition a Modane sur rendez-vous. Prevoyez une demi-journee." }
      ]
    }
  end

  if alpine_listing
    convos_data << {
      listing: alpine_listing, from: marie, to: alpine_listing.user,
      messages: [
        { from: :buyer, text: "L'A110 est magnifique. Avez-vous le rapport de radiographie du chassis ?" },
        { from: :seller, text: "Oui, je l'ai en PDF. L'Atelier Alpine de Dieppe l'a realise lors de la restauration. Je vous l'envoie." },
        { from: :buyer, text: "Parfait. Et les carburateurs Weber sont neufs ou reconditionnes ?" },
        { from: :seller, text: "Neufs, commandes chez Weber Espagne. Les anciens etaient uses au-dela du raisonnable. Facture disponible." }
      ]
    }
  end

  convos_created = 0
  convos_data.each do |cd|
    convo = Conversation.find_or_create_by!(
      listing_id: cd[:listing].id,
      user_id: cd[:from].id,
      other_user_id: cd[:to].id
    )
    next if convo.messages.any?

    cd[:messages].each_with_index do |msg, i|
      sender = msg[:from] == :buyer ? cd[:from] : cd[:to]
      recipient = msg[:from] == :buyer ? cd[:to] : cd[:from]
      Message.create!(
        conversation: convo,
        sender_id: sender.id,
        recipient_id: recipient.id,
        content: msg[:text],
        read: i < cd[:messages].size - 1,
        created_at: (cd[:messages].size - i).hours.ago
      )
    end
    convos_created += 1
  end
  puts "  #{convos_created} conversations created (#{Message.count} messages)"

  # ── FAVORITES ─────────────────────────────────────────────────
  active_listing_ids = Listing.where(status: "active").pluck(:id)
  [lucas, marie, karim].each do |user|
    sampled = active_listing_ids.sample([2, active_listing_ids.size].min)
    sampled.each do |lid|
      Favorite.find_or_create_by!(user_id: user.id, listing_id: lid)
    end
  end
  puts "  #{Favorite.count} favorites"

  # ── LISTING QUESTIONS ─────────────────────────────────────────
  if ListingQuestion.count.zero?
    sample_listing = Listing.where(status: "active").order(:id).first
    if sample_listing
      q = ListingQuestion.create!(
        listing: sample_listing,
        user: marie,
        body: "Le controle technique est-il encore valide ? Date d'expiration ?",
        published: true
      )
      ListingAnswer.create!(
        listing_question: q,
        user: sample_listing.user,
        body: "CT valide jusqu'en mars 2027. Aucune contre-visite, rapport disponible sur demande."
      )
      puts "  1 Q&A on listing ##{sample_listing.id}"
    end
  end
end

puts "Seed complete — #{User.count} users, #{Listing.count} listings, #{Auction.count} auctions, #{Bid.count} bids"
