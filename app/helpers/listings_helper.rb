module ListingsHelper
  # Format éditorial "Annonce N°0472" — padding à 4 chiffres pour numérotation
  # cohérente. Retourne uniquement "N°0472" — l'appelant préfixe si besoin.
  def listing_reference(listing)
    return nil unless listing&.id
    "N°#{listing.id.to_s.rjust(4, '0')}"
  end

  # Tag localisation + type vendeur : "LYON (69) · PARTICULIER"
  # Tente d'extraire un code département depuis la location si présent
  # (format typique "Lyon 69" ou "Paris, 75"), sinon affiche juste la ville.
  def listing_location_tag(listing)
    return nil unless listing&.vehicle&.location.present?

    raw = listing.vehicle.location.to_s.strip
    # Essaie d'extraire un département 2 chiffres en fin de chaîne
    if raw =~ /\A(.+?)[\s,]+(\d{2})\z/
      city = Regexp.last_match(1).strip.upcase
      dept = Regexp.last_match(2)
      location = "#{city} (#{dept})"
    else
      location = raw.upcase
    end

    seller_type = professional_seller?(listing.user) ? "PROFESSIONNEL" : "PARTICULIER"
    "#{location} · #{seller_type}"
  end

  # Prix FR avec espace insécable entre montant et euro : "18 500 €"
  # Utilise l'espace insécable (U+00A0) pour coller l'euro.
  def listing_price_fr(vehicle_or_price)
    amount = vehicle_or_price.respond_to?(:price) ? vehicle_or_price.price : vehicle_or_price
    return nil unless amount

    formatted = number_with_delimiter(amount.to_i, delimiter: " ")
    "#{formatted}\u00A0€"
  end

  # Kilométrage FR avec séparateur espace : "142 500 km"
  def listing_kilometers_fr(kilometers)
    return nil unless kilometers
    "#{number_with_delimiter(kilometers.to_i, delimiter: ' ')}\u00A0km"
  end

  # Segment éditorial dérivé de l'année (pour badge Catalogue)
  def listing_segment(vehicle)
    return nil unless vehicle&.year
    case vehicle.year
    when 1900..1974 then "Classique"
    when 1975..1989 then "Youngtimer"
    when 1990..2004 then "Moderne"
    else "Récent"
    end
  end

  # Inline SVG d'une silhouette véhicule pour la Rust Map.
  # Les fichiers sont stockés dans app/assets/images/silhouettes/*.svg.
  # Défense en profondeur contre une compromission du dossier assets :
  # la variant est allowlisted, le chemin est contenu sous app/assets/images/silhouettes,
  # et on strippe activement les tags dangereux (script, foreignObject, iframe, use href)
  # avant le html_safe.
  SILHOUETTE_DIR = Rails.root.join("app/assets/images/silhouettes").freeze
  DANGEROUS_SVG_TAGS = /<\/?(?:script|foreignObject|iframe|object|embed|link|handler)\b[^>]*>/i.freeze
  DANGEROUS_SVG_ATTRS = /\s(?:on\w+|href|xlink:href|formaction|action)\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>]+)/i.freeze

  def silhouette_svg(variant)
    safe_variant = RustMap::VALID_VARIANTS.include?(variant.to_s) ? variant.to_s : "sedan"
    path = SILHOUETTE_DIR.join("#{safe_variant}.svg").cleanpath
    # Belt-and-braces : s'assurer que le chemin résolu reste sous SILHOUETTE_DIR
    # (parade anti-symlink / path-traversal si un attaquant arrive à planter un
    # fichier avec un nom exotique).
    return "".html_safe unless path.to_s.start_with?(SILHOUETTE_DIR.to_s)
    return "".html_safe unless File.exist?(path)

    raw = File.read(path)
    sanitized = raw.gsub(DANGEROUS_SVG_TAGS, "").gsub(DANGEROUS_SVG_ATTRS, "")
    sanitized.html_safe
  end

  private

  # Stub — à remplacer par un vrai flag user.professional? en Phase DB
  def professional_seller?(user)
    return false unless user
    user.respond_to?(:professional?) ? user.professional? : false
  end
end
