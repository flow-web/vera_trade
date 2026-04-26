module PagesHelper
  HOME_SEGMENTS = [
    {
      key: "youngtimer",
      number: "01",
      name: "Youngtimers",
      examples: "1985 — 1999 · E30 M3, 964,<br>205 GTI, Delta HF",
      deco: "YGT"
    },
    {
      key: "classique",
      number: "02",
      name: "Classique",
      examples: "≤ 1984 · 2CV, DS,<br>504 Coupé, Alfa 75",
      deco: "CLA"
    },
    {
      key: "moderne",
      number: "03",
      name: "Moderne",
      examples: "2000 — 2015 · M3 E92,<br>997 Turbo, Evo IX, STI",
      deco: "MOD"
    },
    {
      key: "recent",
      number: "04",
      name: "Récent",
      examples: "≥ 2016 · GT3 RS,<br>Civic Type R, RS3",
      deco: "REC"
    }
  ].freeze

  HOME_TRUST = [
    {
      title: "Escrow sécurisé",
      sub: "Fonds bloqués jusqu'à livraison",
      svg: '<path d="M12 2 4 5v6c0 5 3.5 9.5 8 11 4.5-1.5 8-6 8-11V5l-8-3z"/><path d="m9 12 2 2 4-4"/>'
    },
    {
      title: "Inspection experte",
      sub: "Réseau d'experts par marque",
      svg: '<circle cx="12" cy="12" r="9"/><path d="M9 12l2 2 4-4"/>'
    },
    {
      title: "Provenance documentée",
      sub: "Carnet, factures, ex-propriétaires",
      svg: '<rect x="3" y="4" width="18" height="16" rx="1"/><path d="M3 10h18M8 4v4M16 4v4"/>'
    },
    {
      title: "Q&R publiques",
      sub: "La communauté pose les bonnes questions",
      svg: '<path d="M3 7h18M3 12h18M3 17h18"/>'
    },
    {
      title: "Échange + soulte",
      sub: "3 clics, encadré juridiquement",
      svg: '<circle cx="12" cy="12" r="9"/><path d="M12 3v18M5 12h14"/>'
    }
  ].freeze

  HOME_SELL_STEPS = [
    {
      number: "01",
      title: "Identification & châssis",
      desc: "Marque, modèle, génération, numéro de châssis. Croisé HistoVec automatiquement.",
      time: "~3 min"
    },
    {
      number: "02",
      title: "Rust map interactive",
      desc: "Vous pointez les zones à problème sur le schéma — vous prouvez votre transparence.",
      time: "~12 min"
    },
    {
      number: "03",
      title: "Originalité & matching numbers",
      desc: "Score automatique basé sur la documentation constructeur du modèle.",
      time: "~5 min"
    },
    {
      number: "04",
      title: "Récit éditorial & documents",
      desc: "On vous aide à raconter l'histoire. Carnet, factures, CT, FFVE — OCR auto.",
      time: "~25 min"
    }
  ].freeze

  HOME_POPULAR_SEARCHES = [
    { label: "JDM 90s", path_query: { make: "Honda" } },
    { label: "E30 M3", path_query: { make: "BMW" } },
    { label: "Porsche 964", path_query: { make: "Porsche" } },
    { label: "Préparation rallye", path_query: { make: "Lancia" } },
    { label: "Sous 25 K€", path_query: { price_max: "25000" } },
    { label: "RHD & imports", path_query: { transmission: "Manuelle" } }
  ].freeze

  def home_segments
    HOME_SEGMENTS
  end

  def home_trust_pillars
    HOME_TRUST
  end

  def home_sell_steps
    HOME_SELL_STEPS
  end

  def home_popular_searches
    HOME_POPULAR_SEARCHES
  end

  def segment_label(key)
    case key.to_s
    when "classique" then "Classique"
    when "youngtimer" then "Youngtimer"
    when "moderne"   then "Moderne"
    when "recent"    then "Récent"
    else key.to_s.capitalize
    end
  end
end
