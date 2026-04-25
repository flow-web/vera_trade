# Editorial upgrade — 5 annonces transformées en articles magazine
# Usage: bin/rails runner db/editorial_upgrade.rb

EDITORIAL = [
  {
    match_title: "Lancia Delta",
    title: "Lancia Delta HF Integrale Evoluzione — 1993",
    description: <<~MD,
      Dernière évolution de la mythique Delta HF Integrale, cet exemplaire Giallo Ginestra est l'un des 220 produits dans cette teinte d'usine exclusive. Livrée neuve en mars 1993 chez le concessionnaire Lancia de Turin, la voiture a été conservée par deux propriétaires italiens successifs avant d'être importée en France en 2021.

      Le 2.0 litres turbo 16 soupapes développe 215 chevaux, transmis aux quatre roues motrices via la boîte manuelle à 5 rapports. Le compteur affiche 78 420 km d'origine, accompagnés d'un carnet d'entretien intégral depuis la livraison. La distribution a été refaite en 2024.

      Une restauration sélective de la carrosserie a été confiée aux ateliers Officine Faralli en 2019 — seuls les éléments strictement nécessaires ont été traités, préservant la patine d'origine sur les parties saines. Le moteur a reçu un service complet en janvier 2026 à Turin.

      L'intérieur d'origine est en excellent état : sièges Recaro spécifiques Evo II, volant Momo Corse, moquettes propres sans déchirures. Le dossier d'entretien comprend 22 factures, le certificat Lancia Heritage, et le rapport d'inspection 148 points de Vera Trade.
    MD
    vehicle_attrs: {
      exterior_color: "Giallo Ginestra (Jaune Genêt)",
      interior_color: "Alcantara noir d'origine",
      interior_material: "Alcantara",
      interior_condition: "Excellent — sièges Recaro Evo II d'origine",
      body_condition: "Très bon — restauration sélective Faralli 2019",
      tire_condition: "Pirelli P Zero — montées en 2025, 4000 km",
      cylinder_capacity: 1995,
      previous_owners: 3,
      has_service_history: true,
      recent_works: "Distribution refaite 2024, service moteur complet Turin janv. 2026",
      comfort_features: "Climatisation d'origine, vitres électriques, verrouillage centralisé",
      safety_features: "ABS, airbag conducteur",
      location: "Lyon, France"
    },
    rust_map: {
      silhouette_variant: "hatch",
      transparency_score: 82,
      notes: "Inspection réalisée le 12 avril 2026 par Expert Vera Trade. État général très satisfaisant pour un véhicule de 33 ans.",
      zones: [
        { x: 15.2, y: 72.0, status: "ok", label: "Passage de roue avant droit" },
        { x: 42.5, y: 68.0, status: "surface", label: "Bas de caisse droit", note: "Points de surface traités en 2019, surveillance recommandée" },
        { x: 85.0, y: 72.0, status: "ok", label: "Passage de roue arrière droit" },
        { x: 50.0, y: 85.0, status: "ok", label: "Plancher central" },
        { x: 90.0, y: 60.0, status: "surface", label: "Panneau arrière sous hayon", note: "Légère oxydation superficielle, non perforante" },
        { x: 10.0, y: 45.0, status: "ok", label: "Capot" },
        { x: 50.0, y: 30.0, status: "ok", label: "Pavillon" },
        { x: 30.0, y: 55.0, status: "ok", label: "Portière avant gauche" },
        { x: 70.0, y: 55.0, status: "ok", label: "Portière arrière gauche" },
      ]
    },
    questions: [
      { q: "Le bloc moteur a-t-il déjà été ouvert ?", a: "Jamais ouvert. Le suivi d'atelier ne mentionne que les vidanges standard et la distribution refaite en 2024. Le numéro moteur d'origine est lisible et conforme aux papiers." },
      { q: "Le catalyseur d'origine est-il encore en place ?", a: "Oui, pièce d'origine avec estampille Lancia visible. Photos disponibles dans la galerie, onglet « Dessous de caisse »." },
    ]
  },
  {
    match_title: "Porsche",
    title: "Porsche 911 (964) Carrera RS — 1991",
    description: <<~MD,
      La 964 Carrera RS reste l'une des 911 les plus désirables jamais produites. Allégée de 155 kg par rapport à la Carrera 2 standard, elle combine le flat-six 3.6 litres de 260 chevaux avec un châssis affûté pour la route et le circuit.

      Cet exemplaire Rouge Guards d'origine a été livré neuf en Allemagne en septembre 1991. Il fait partie des 2 282 exemplaires produits pour le marché mondial. Le compteur affiche 48 200 km certifiés par Porsche Classic, avec un carnet d'entretien sans interruption depuis la livraison.

      La voiture conserve ses numéros matching — moteur, boîte, châssis — et n'a subi aucune transformation par rapport à la spécification d'usine. Les jantes Fuchs 17 pouces d'origine chaussent des Michelin Pilot Sport récents. L'intérieur dépouillé (suppression de l'isolation phonique, sièges baquets Recaro, pas de climatisation ni de vitres électriques) témoigne de la vocation sportive du modèle.

      Le dossier comprend le Certificate of Authenticity Porsche, l'historique complet des révisions chez des centres Porsche agréés, et un rapport d'inspection indépendant de 2025.
    MD
    vehicle_attrs: {
      exterior_color: "Rouge Guards (Indischrot)",
      interior_color: "Noir",
      interior_material: "Cuir / tissu sport",
      interior_condition: "Excellent — sièges Recaro baquets d'usine",
      body_condition: "Exceptionnel — peinture d'origine sur les 4 faces",
      tire_condition: "Michelin Pilot Sport 4S — montées en 2025",
      cylinder_capacity: 3600,
      previous_owners: 2,
      has_service_history: true,
      recent_works: "Révision majeure Porsche Classic Stuttgart, octobre 2025",
      location: "Stuttgart, Allemagne"
    },
    rust_map: {
      silhouette_variant: "coupe",
      transparency_score: 96,
      notes: "Carrosserie aluminium et galvanisation Porsche. Véhicule exceptionnel, aucun point de corrosion détecté.",
      zones: [
        { x: 15.0, y: 70.0, status: "ok", label: "Passage de roue avant" },
        { x: 40.0, y: 68.0, status: "ok", label: "Bas de caisse droit" },
        { x: 85.0, y: 70.0, status: "ok", label: "Passage de roue arrière" },
        { x: 50.0, y: 80.0, status: "ok", label: "Plancher" },
        { x: 10.0, y: 40.0, status: "ok", label: "Capot avant (coffre)" },
        { x: 90.0, y: 40.0, status: "ok", label: "Capot moteur arrière" },
      ]
    },
    questions: [
      { q: "Est-ce un modèle Touring ou Sport ?", a: "C'est la version Sport (M003) avec arceau de sécurité soudé, volant à 3 branches et banquette arrière supprimée. La plus radicale des deux versions proposées par Porsche." },
      { q: "La boîte de vitesses présente-t-elle du jeu ?", a: "Aucun jeu anormal. La boîte G50/10 a été révisée lors du dernier service chez Porsche Classic. Synchros souples sur les 5 rapports." },
    ]
  },
  {
    match_title: "Alpine",
    title: "Alpine A110 Berlinette 1600 S — 1973",
    description: <<~MD,
      L'Alpine A110 incarne cinquante ans de passion automobile française. Cette Berlinette 1600 S de 1973, en livrée Bleu Alpine métallisé d'origine, a passé toute sa vie dans la même famille — deux propriétaires, père et fils, depuis sa sortie de l'usine de Dieppe.

      Le moteur 1.6 litres Gordini développe 127 chevaux, un rapport poids/puissance remarquable pour une voiture de 720 kg. La transmission manuelle à 5 rapports envoie la puissance aux roues arrière via un différentiel à glissement limité.

      La carrosserie en polyester sur châssis poutre est naturellement immunisée contre la corrosion. L'état de conservation est remarquable : peinture d'origine sous vernis, phares Cibie Iode d'époque, pare-chocs chromés en bel état. L'intérieur conserve son volant Moto-Lita à 3 branches, ses sièges baquets d'origine retapissés en cuir noir en 2018, et sa sellerie de pavillon sans affaissement.

      Documentation complète : carte grise d'origine, facture d'achat 1973, historique des contrôles techniques depuis 1992, et certificat FFVE délivré en 2020 pour la plaque de collection.
    MD
    vehicle_attrs: {
      exterior_color: "Bleu Alpine métallisé",
      interior_color: "Cuir noir",
      interior_material: "Cuir",
      interior_condition: "Très bon — sièges retapissés 2018, pavillon d'origine",
      body_condition: "Remarquable — polyester d'origine, pas de corrosion possible",
      tire_condition: "Michelin XAS FF — reproduction fidèle du pneumatique d'époque",
      cylinder_capacity: 1596,
      previous_owners: 2,
      has_service_history: true,
      recent_works: "Réfection des freins AV+AR 2024, liquides refaits intégralement",
      location: "Dieppe, France"
    },
    rust_map: {
      silhouette_variant: "coupe",
      transparency_score: 98,
      notes: "Carrosserie polyester — pas de corrosion structurelle possible. Châssis poutre acier inspecté : aucun point faible.",
      zones: [
        { x: 50.0, y: 85.0, status: "ok", label: "Châssis poutre central" },
        { x: 15.0, y: 75.0, status: "ok", label: "Train avant" },
        { x: 85.0, y: 75.0, status: "ok", label: "Berceau moteur arrière" },
        { x: 50.0, y: 50.0, status: "ok", label: "Coque polyester" },
      ]
    },
    questions: [
      { q: "Le moteur est-il d'origine ou échangé standard ?", a: "Moteur d'origine, numéro matching visible sur le bloc. Jamais ouvert — seul l'entretien courant et un remplacement de la pompe à eau en 2015." },
    ]
  },
  {
    match_title: "BMW M3",
    title: "BMW M3 (E30) Evolution II — 1988",
    description: <<~MD,
      Produite à seulement 500 exemplaires pour homologuer la version course du Groupe A, l'Evolution II est le Graal de la gamme E30. Ce modèle se distingue par son aileron arrière à double plan, ses extensions d'ailes élargies et son moteur S14 2.3 litres porté à 220 chevaux.

      Cet exemplaire Alpinweiss II d'origine sort de chez BMW München en novembre 1988. Il comptabilise 112 300 km avec un historique BMW ininterrompu. Le propriétaire actuel, collectionneur munichois, l'a acquis en 2012 avec 78 000 km et en a fait un usage exclusivement routier — jamais de piste.

      Le moteur S14B23 catalysé reste dans sa configuration d'usine. La boîte Getrag 265/5 passe les rapports avec précision. Le différentiel autobloquant à 25 % fonctionne nominalement. Les freins ABS ont été révisés intégralement en 2024 avec des disques et plaquettes neufs.

      L'intérieur en tissu sport anthracite est en état remarquable pour le kilométrage. Le volant M-Technik II à 3 branches ne présente ni usure ni craquelure. Le tableau de bord est exempt de fissures — un point rare sur les E30 de cet âge.
    MD
    vehicle_attrs: {
      exterior_color: "Alpinweiss II (Blanc Alpin)",
      interior_color: "Anthracite",
      interior_material: "Tissu sport M",
      interior_condition: "Remarquable — volant M-Technik II sans usure, pas de fissures tableau de bord",
      body_condition: "Très bon — peinture d'origine sauf aile ARG (retouchée 2015)",
      tire_condition: "Continental SportContact 6 — neufs 2025",
      cylinder_capacity: 2302,
      previous_owners: 3,
      has_service_history: true,
      recent_works: "Freins AV+AR complets 2024, silent-blocs train avant 2023",
      location: "Munich, Allemagne"
    },
    rust_map: {
      silhouette_variant: "sedan",
      transparency_score: 78,
      notes: "Points sensibles E30 classiques vérifiés. Traitement Dinitrol complet effectué en 2020.",
      zones: [
        { x: 15.0, y: 72.0, status: "ok", label: "Passage de roue avant droit" },
        { x: 42.0, y: 70.0, status: "ok", label: "Bas de caisse droit" },
        { x: 85.0, y: 72.0, status: "surface", label: "Passage de roue arrière droit", note: "Trace de reprise visible, traitement anti-corrosion appliqué 2020" },
        { x: 42.0, y: 40.0, status: "ok", label: "Bas de caisse gauche" },
        { x: 85.0, y: 40.0, status: "ok", label: "Passage de roue arrière gauche" },
        { x: 50.0, y: 85.0, status: "ok", label: "Plancher" },
        { x: 92.0, y: 60.0, status: "surface", label: "Plancher coffre", note: "Surface saine mais surveillance recommandée — zone connue E30" },
      ]
    },
    questions: [
      { q: "Le catalyseur est-il d'origine ?", a: "Oui, catalyseur d'usine en place. Version catalysée 220 ch (vs 238 ch non-cat). Conforme aux papiers allemands." },
      { q: "L'aileron Evolution II est-il authentique ?", a: "Oui, aileron double plan d'usine. Numéro de pièce BMW visible dessous, cohérent avec le numéro de série Evo II. Ce n'est pas un retrofit." },
    ]
  },
  {
    match_title: "Peugeot 205",
    title: "Peugeot 205 GTI 1.9 Phase 1 — 1988",
    description: <<~MD,
      La 205 GTI 1.9 Phase 1 est devenue en quelques années l'une des youngtimers françaises les plus recherchées. Son 1.9 litres atmosphérique de 130 chevaux dans une caisse de 875 kg offre une expérience de conduite que les voitures modernes ne peuvent plus reproduire.

      Cet exemplaire Rouge Vallelunga de 1988 est une Phase 1 authentique, identifiable à ses répétiteurs d'ailes lisses, son tableau de bord à fond gris et ses sièges à passepoil rouge. Le compteur affiche 138 000 km d'origine, un kilométrage cohérent pour une GTI de cet âge qui a réellement été utilisée et entretenue.

      Le moteur XU9 JA tourne rond, sans fumée ni cliquetis. La boîte BE3 à 5 rapports craque légèrement en première à froid — comportement normal et documenté sur ce modèle. L'embrayage a été remplacé à 125 000 km.

      La carrosserie est en bon état pour une 205 : pas de corrosion perforante, les ailes avant ont été remplacées il y a environ 5 ans. La peinture Rouge Vallelunga présente l'oxydation caractéristique du vernis monocouche d'époque — une correction peinture permettrait de retrouver l'éclat d'origine. L'intérieur est complet et d'origine.
    MD
    vehicle_attrs: {
      exterior_color: "Rouge Vallelunga (EKB)",
      interior_color: "Gris Biarritz à passepoil rouge",
      interior_material: "Tissu velours",
      interior_condition: "Bon — sièges à passepoil d'origine, usure normale conducteur",
      body_condition: "Bon — ailes AV remplacées, pas de perforation",
      tire_condition: "Toyo Proxes TR1 185/55 R15 — 8000 km",
      cylinder_capacity: 1905,
      previous_owners: 4,
      has_service_history: true,
      recent_works: "Embrayage neuf à 125 000 km, silents-blocs AV 2024, liquide de frein 2025",
      location: "Lyon, France"
    },
    rust_map: {
      silhouette_variant: "hatch",
      transparency_score: 68,
      notes: "Points sensibles 205 classiques inspectés. Carrosserie saine structurellement mais surveillance recommandée sur les zones habituelles.",
      zones: [
        { x: 15.0, y: 72.0, status: "ok", label: "Passage de roue avant droit" },
        { x: 42.0, y: 70.0, status: "surface", label: "Bas de caisse droit", note: "Bullage léger sous anti-gravillons — non perforant, traitement préventif conseillé" },
        { x: 85.0, y: 72.0, status: "surface", label: "Passage de roue arrière droit", note: "Trace de reprise ancienne, mastic visible, état stable" },
        { x: 42.0, y: 40.0, status: "ok", label: "Bas de caisse gauche" },
        { x: 85.0, y: 40.0, status: "surface", label: "Passage de roue arrière gauche", note: "Léger bullage similaire au côté droit" },
        { x: 50.0, y: 85.0, status: "ok", label: "Plancher habitacle" },
        { x: 92.0, y: 60.0, status: "ok", label: "Plancher coffre" },
        { x: 10.0, y: 60.0, status: "ok", label: "Tablier avant" },
      ]
    },
    questions: [
      { q: "La boîte craque vraiment en première ?", a: "Oui, légèrement à froid uniquement. C'est le comportement normal de la BE3 sur les 205 GTI — les synchros de première s'usent avec le temps. Aucun impact sur la fiabilité, c'est cosmétique." },
      { q: "Les ailes avant sont-elles d'origine ?", a: "Non, elles ont été remplacées par des ailes neuves Peugeot il y a ~5 ans suite à de la corrosion perforante. Pose propre, ajustement correct, apprêtées et peintes en Rouge Vallelunga." },
    ]
  }
]

puts "Upgrading 5 listings to editorial quality..."

admin = User.find_by(role: [1, 2]) || User.first
bidder = User.where.not(id: admin.id).first

EDITORIAL.each_with_index do |ed, idx|
  listing = Listing.where("title ILIKE ?", "%#{ed[:match_title]}%").first
  unless listing
    puts "  SKIP: no listing matching '#{ed[:match_title]}'"
    next
  end

  listing.update!(
    title: ed[:title],
    description: ed[:description].strip,
    is_certified: true,
    status: "active"
  )

  v = listing.vehicle
  v.update!(ed[:vehicle_attrs]) if ed[:vehicle_attrs].present?

  if ed[:rust_map]
    rm = listing.rust_map || listing.create_rust_map!
    rm.update!(
      silhouette_variant: ed[:rust_map][:silhouette_variant],
      transparency_score: ed[:rust_map][:transparency_score],
      notes: ed[:rust_map][:notes]
    )
    rm.rust_zones.destroy_all rescue nil
    RustZone.where(rust_map_id: rm.id).delete_all
    ed[:rust_map][:zones].each_with_index do |z, i|
      RustZone.create!(
        rust_map_id: rm.id,
        x_pct: z[:x],
        y_pct: z[:y],
        status: z[:status],
        label: z[:label],
        note: z[:note],
        position: i
      )
    end
  end

  if ed[:questions] && bidder
    ed[:questions].each do |qa|
      question = listing.listing_questions.find_or_create_by!(body: qa[:q]) do |q|
        q.user = bidder
        q.published = true
      end
      unless question.answer
        ListingAnswer.create!(
          listing_question: question,
          user: listing.user,
          body: qa[:a]
        )
      end
    end
  end

  puts "  ✓ #{ed[:title]}"
end

puts "Editorial upgrade complete."
