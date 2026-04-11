class ListingWizardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:edit, :update, :save_step, :publish]
  before_action :ensure_owner, only: [:edit, :update, :save_step, :publish]

  STEPS = %w[vehicle photos rust_map mechanics history documents review].freeze

  def new
    vehicle = Vehicle.create!(
      make: "À définir",
      model: "À définir",
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
    redirect_to edit_listing_wizard_path(listing)
  end

  def edit
    @current_step = (@listing.wizard_step || 0).to_i.clamp(0, STEPS.size - 1)
    @step_key = STEPS[@current_step]
  end

  # save_step est la seule action de transition : elle merge les données de
  # l'étape dans draft_data, puis positionne wizard_step sur target_step (explicite
  # pour permettre back/next/jump sans ambiguïté).
  def save_step
    incoming_step = params[:step].to_i
    target_step = params[:target_step].present? ? params[:target_step].to_i : incoming_step + 1
    target_step = target_step.clamp(0, STEPS.size - 1)

    merged = (@listing.draft_data || {}).deep_merge(normalized_draft_data)
    @listing.update!(draft_data: merged, wizard_step: target_step)

    # Side-effect persistance par étape
    case incoming_step
    when 1 then persist_photos!
    when 2 then persist_rust_map!
    when 3 then persist_originality_and_mechanics!
    when 4 then persist_provenance_events!
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
                  alert: "Complétez les champs requis avant publication (véhicule, photos, Rust Map)."
      return
    end

    sync_vehicle_from_draft!
    @listing.update!(status: "active", published_at: Time.current)
    redirect_to listing_path(@listing), notice: "Annonce publiée."
  end

  private

  def set_listing
    @listing = current_user.listings.find_by(slug: params[:id]) || current_user.listings.find(params[:id])
  end

  def ensure_owner
    redirect_to listings_path, alert: "Non autorisé." unless @listing.user == current_user
  end

  def normalized_draft_data
    raw = params.fetch(:listing, {})[:draft_data]
    return {} unless raw

    case raw
    when ActionController::Parameters then raw.permit!.to_h
    when Hash then raw
    else {}
    end
  end

  def persist_photos!
    if params.dig(:listing, :photos).present?
      @listing.photos.attach(params[:listing][:photos])
    end
  end

  def persist_rust_map!
    draft_rm = @listing.draft_data.dig("rust_map") || {}
    rm = @listing.rust_map || @listing.build_rust_map
    rm.silhouette_variant = draft_rm["silhouette_variant"] || "sedan"
    rm.save!

    rm.zones.destroy_all
    parsed_zones = begin
      raw = draft_rm["zones"]
      raw.is_a?(String) ? JSON.parse(raw) : (raw || [])
    rescue JSON::ParserError
      []
    end

    parsed_zones.each_with_index do |z, idx|
      rm.zones.create!(
        x_pct: z["x"].to_f,
        y_pct: z["y"].to_f,
        status: z["status"] || "ok",
        label: z["label"],
        note: z["note"],
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
    os.original_paint_pct = draft["original_paint_pct"].to_i
    os.overall_score = compute_overall_originality(os)
    os.save!
  end

  def persist_provenance_events!
    events = @listing.draft_data.dig("provenance_events") || []
    @listing.provenance_events.destroy_all
    Array(events).each_with_index do |e, idx|
      next if e.is_a?(Hash) && (e["label"].blank? || e["event_year"].blank?)
      @listing.provenance_events.create!(
        event_year: e["event_year"].to_i,
        event_type: e["event_type"].presence || "service",
        label: e["label"],
        description: e["description"],
        position: idx
      )
    end
  end

  def compute_overall_originality(os)
    score = 0
    score += 40 if os.matching_numbers
    score += 20 if os.original_interior
    score += (os.original_paint_pct.to_i * 0.4).round
    [score, 100].min
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
