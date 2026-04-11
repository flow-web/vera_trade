class ListingWizardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [ :edit, :update, :save_step, :publish ]

  STEPS = %w[vehicle photos rust_map mechanics history documents review].freeze
  MAX_DRAFTS_PER_USER = 5
  MAX_RUST_ZONES = 50
  MAX_PROVENANCE_EVENTS = 30
  MAX_STRING_LEN = 500

  rescue_from ActiveRecord::RecordInvalid do |e|
    redirect_back_or_to(listings_path, alert: "Erreur de validation : #{e.record.errors.full_messages.to_sentence}")
  end

  # new est idempotent : s'il y a déjà un draft en cours, on y redirige.
  # Sinon on en crée un nouveau dans la limite de MAX_DRAFTS_PER_USER.
  def new
    existing = current_user.listings.draft.order(created_at: :desc).first
    if existing
      redirect_to edit_listing_wizard_path(existing)
      return
    end

    if current_user.listings.draft.count >= MAX_DRAFTS_PER_USER
      redirect_to my_listings_path,
                  alert: "Vous avez atteint la limite de #{MAX_DRAFTS_PER_USER} brouillons. Supprimez-en un avant d'en créer un nouveau."
      return
    end

    listing = nil
    ActiveRecord::Base.transaction do
      vehicle = Vehicle.create!(
        make: Listing::VEHICLE_STUB_STRING,
        model: Listing::VEHICLE_STUB_STRING,
        year: Date.current.year,
        price: 1
      )
      listing = current_user.listings.create!(
        title: "Brouillon — #{Time.current.strftime('%d/%m/%Y %H:%M')}",
        description: "Brouillon en cours de rédaction.",
        status: "draft",
        wizard_step: 0,
        draft_data: {},
        vehicle: vehicle
      )
    end
    redirect_to edit_listing_wizard_path(listing)
  end

  def edit
    @current_step = (@listing.wizard_step || 0).to_i.clamp(0, STEPS.size - 1)
    @step_key = STEPS[@current_step]
  end

  # save_step est la seule action de transition : elle merge les données de
  # l'étape dans draft_data, puis positionne wizard_step sur target_step (explicite
  # pour permettre back/next/jump sans ambiguïté). Toutes les opérations sont
  # enveloppées dans une transaction — en cas d'erreur, rien n'est persisté.
  def save_step
    incoming_step = params[:step].to_i
    target_step = params[:target_step].present? ? params[:target_step].to_i : incoming_step + 1
    target_step = target_step.clamp(0, STEPS.size - 1)

    # Cap checks avant d'ouvrir la transaction — on veut retourner 400 net,
    # pas un état transactionnel half-rolled-back.
    if limit_error = validate_step_limits(incoming_step)
      render plain: limit_error, status: :bad_request
      return
    end

    ActiveRecord::Base.transaction do
      merged = (@listing.draft_data || {}).deep_merge(normalized_draft_data)
      @listing.update!(draft_data: merged, wizard_step: target_step)

      # Side-effect persistance par étape (toutes dans la même transaction)
      case incoming_step
      when 1 then persist_photos!
      when 2 then persist_rust_map!
      when 3 then persist_originality_and_mechanics!
      when 4 then persist_provenance_events!
      end
    end

    @current_step = target_step
    @step_key = STEPS[target_step]

    respond_to do |fmt|
      fmt.turbo_stream
      fmt.html { redirect_to edit_listing_wizard_path(@listing) }
    end
  end

  def update
    save_step
  end

  def publish
    unless @listing.publishable?
      redirect_to edit_listing_wizard_path(@listing),
                  alert: "Complétez les champs requis avant publication (véhicule renseigné, au moins une photo, Rust Map initialisée)."
      return
    end

    # Lock pour éviter double-publish concurrent.
    @listing.with_lock do
      return redirect_to(listing_path(@listing), notice: "Annonce déjà publiée.") unless @listing.draft?

      ActiveRecord::Base.transaction do
        sync_vehicle_from_draft!
        @listing.update!(status: "active", published_at: Time.current)
      end
    end

    redirect_to listing_path(@listing), notice: "Annonce publiée."
  end

  private

  # Vérifie les caps de taille par étape AVANT de rentrer en transaction.
  # Retourne une string d'erreur si violation, nil sinon.
  def validate_step_limits(incoming_step)
    case incoming_step
    when 2
      raw_zones = params.dig(:listing, :draft_data, :rust_map, :zones)
      return nil if raw_zones.blank?
      parsed = begin
        raw_zones.is_a?(String) ? JSON.parse(raw_zones) : raw_zones
      rescue JSON::ParserError
        return nil
      end
      return nil unless parsed.is_a?(Array)
      return "Maximum #{MAX_RUST_ZONES} zones par Rust Map." if parsed.size > MAX_RUST_ZONES
    when 4
      events = params.dig(:listing, :draft_data, :provenance_events)
      return nil unless events.is_a?(Array) || events.is_a?(ActionController::Parameters)
      arr = events.is_a?(ActionController::Parameters) ? events.to_unsafe_h.values : events
      return "Maximum #{MAX_PROVENANCE_EVENTS} événements de provenance." if arr.size > MAX_PROVENANCE_EVENTS
    end
    nil
  end

  def set_listing
    @listing = current_user.listings.find_by(slug: params[:id]) ||
               current_user.listings.find_by(id: params[:id])
    # set_listing étant scopé sur current_user.listings, un nil ici signifie
    # que la ressource n'existe pas OU ne nous appartient pas — 404 transparent.
    raise ActiveRecord::RecordNotFound unless @listing
  end

  # Per-step strong params allowlist. Rejects any key not expected for the
  # submitted step — no permit!, no arbitrary JSONB writes.
  def normalized_draft_data
    raw = params.fetch(:listing, {})[:draft_data]
    return {} unless raw.is_a?(ActionController::Parameters) || raw.is_a?(Hash)
    raw = ActionController::Parameters.new(raw) if raw.is_a?(Hash)

    step_index = params[:step].to_i
    permitted = case step_index
    when 0 # Vehicle
      raw.permit(vehicle: %i[make model year kilometers price location vin license_plate fuel_type transmission])
    when 1 # Photos — l'upload est multipart, draft_data est vide ici.
      ActionController::Parameters.new({}).permit!
    when 2 # Rust Map (zones est un JSON string sérialisé côté Stimulus)
      raw.permit(rust_map: [ :silhouette_variant, :zones ])
    when 3 # Mechanics + Originality
      raw.permit(
        mechanics: %i[engine_type transmission recent_works],
        originality: %i[matching_numbers original_interior original_paint_pct]
      )
    when 4 # Provenance — tableau d'événements
      raw.permit(provenance_events: %i[event_year event_type label description])
    when 5 # Documents
      raw.permit(documents: %i[ct_date ct_expiry service_book notes])
    else
      ActionController::Parameters.new({}).permit!
    end

    truncate_strings(permitted.to_h)
  end

  # Coupe récursivement les strings à MAX_STRING_LEN caractères — limite la
  # taille des champs textarea (notes, description) pour éviter d'exploser la
  # taille du jsonb draft_data.
  def truncate_strings(obj)
    case obj
    when String then obj.byteslice(0, MAX_STRING_LEN * 4)&.force_encoding("UTF-8")&.scrub&.slice(0, MAX_STRING_LEN).to_s
    when Array then obj.map { |v| truncate_strings(v) }
    when Hash then obj.transform_values { |v| truncate_strings(v) }
    else obj
    end
  end

  def persist_photos!
    return unless params.dig(:listing, :photos).present?

    incoming = Array(params[:listing][:photos]).reject(&:blank?)
    return if incoming.empty?

    # Cap dur : empêche l'attachement si ça dépasse la limite du modèle.
    if @listing.photos.count + incoming.size > Listing::PHOTO_MAX_COUNT
      raise ActiveRecord::RecordInvalid.new(@listing).tap { |e|
        @listing.errors.add(:photos, "maximum #{Listing::PHOTO_MAX_COUNT} photos au total")
      }
    end
    @listing.photos.attach(incoming)
    @listing.save! # déclenche les validators Active Storage (content_type, size)
  end

  def persist_rust_map!
    draft_rm = @listing.draft_data.dig("rust_map") || {}
    rm = @listing.rust_map || @listing.build_rust_map
    rm.silhouette_variant = draft_rm["silhouette_variant"].to_s
    rm.save!

    parsed_zones = begin
      raw = draft_rm["zones"]
      parsed = raw.is_a?(String) ? JSON.parse(raw) : (raw || [])
      parsed.is_a?(Array) ? parsed : []
    rescue JSON::ParserError
      []
    end
    # Cap validé amont via validate_step_limits — ici on tronque au cas où.
    parsed_zones = parsed_zones.first(MAX_RUST_ZONES)

    rm.zones.destroy_all
    parsed_zones.each_with_index do |z, idx|
      next unless z.is_a?(Hash)
      rm.zones.create!(
        x_pct: z["x"].to_f.clamp(0, 100),
        y_pct: z["y"].to_f.clamp(0, 100),
        status: RustZone::VALID_STATUSES.include?(z["status"]) ? z["status"] : "ok",
        label: z["label"].to_s.slice(0, MAX_STRING_LEN),
        note: z["note"].to_s.slice(0, MAX_STRING_LEN),
        position: idx
      )
    end
    rm.recompute_score!
  end

  def persist_originality_and_mechanics!
    draft = @listing.draft_data.dig("originality") || {}
    os = @listing.originality_score || @listing.build_originality_score
    os.matching_numbers = draft["matching_numbers"].to_s == "1"
    os.original_interior = draft["original_interior"].to_s == "1"
    os.original_paint_pct = draft["original_paint_pct"].to_i.clamp(0, 100)
    os.overall_score = compute_overall_originality(os)
    os.save!
  end

  def persist_provenance_events!
    events = Array(@listing.draft_data.dig("provenance_events") || []).first(MAX_PROVENANCE_EVENTS)

    @listing.provenance_events.destroy_all
    events.each_with_index do |e, idx|
      next unless e.is_a?(Hash)
      next if e["label"].blank? || e["event_year"].blank?

      year = e["event_year"].to_i
      next if year < 1900 || year > 2100

      @listing.provenance_events.create!(
        event_year: year,
        event_type: ProvenanceEvent::VALID_TYPES.include?(e["event_type"]) ? e["event_type"] : "service",
        label: e["label"].to_s.slice(0, MAX_STRING_LEN),
        description: e["description"].to_s.slice(0, MAX_STRING_LEN),
        position: idx
      )
    end
  end

  def compute_overall_originality(os)
    score = 0
    score += 40 if os.matching_numbers
    score += 20 if os.original_interior
    score += (os.original_paint_pct.to_i * 0.4).round
    [ score, 100 ].min
  end

  def sync_vehicle_from_draft!
    v_data = @listing.draft_data.dig("vehicle") || {}
    return if v_data.empty?

    attrs = {
      make: v_data["make"].presence,
      model: v_data["model"].presence,
      year: v_data["year"].presence&.to_i,
      price: v_data["price"].presence&.to_f,
      kilometers: v_data["kilometers"].presence&.to_i,
      location: v_data["location"].presence,
      vin: v_data["vin"].presence,
      license_plate: v_data["license_plate"].presence,
      fuel_type: v_data["fuel_type"].presence,
      transmission: v_data["transmission"].presence
    }.compact

    @listing.vehicle.update!(attrs) if attrs.any?
  end
end
