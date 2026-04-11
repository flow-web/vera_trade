require "test_helper"

class ListingWizardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "new creates a fresh draft listing and redirects to edit step 0" do
    assert_difference -> { Listing.count } => 1, -> { Vehicle.count } => 1 do
      get new_listing_wizard_path
    end
    listing = Listing.order(created_at: :desc).first
    assert_redirected_to edit_listing_wizard_path(listing)
    assert listing.draft?
    assert_equal 0, listing.wizard_step
    assert_equal @user, listing.user
  end

  test "edit renders step 0 layout" do
    get new_listing_wizard_path
    listing = Listing.order(created_at: :desc).first

    get edit_listing_wizard_path(listing)
    assert_response :success
    assert_select "[data-controller~='listing-wizard']"
  end

  test "save_step merges draft_data and advances wizard_step" do
    get new_listing_wizard_path
    listing = Listing.order(created_at: :desc).first

    patch save_step_listing_wizard_path(listing), params: {
      step: 0,
      listing: { draft_data: { vehicle: { make: "Citroën", model: "CX" } } }
    }, as: :turbo_stream

    assert_response :success
    listing.reload
    assert_equal 1, listing.wizard_step
    assert_equal "Citroën", listing.draft_data.dig("vehicle", "make")
    assert_equal "CX", listing.draft_data.dig("vehicle", "model")
  end

  test "save_step respects explicit target_step for back navigation" do
    get new_listing_wizard_path
    listing = Listing.order(created_at: :desc).first
    listing.update!(wizard_step: 3)

    patch save_step_listing_wizard_path(listing), params: {
      step: 3,
      target_step: 2,
      listing: { draft_data: {} }
    }, as: :turbo_stream

    assert_response :success
    assert_equal 2, listing.reload.wizard_step
  end

  test "save_step persists rust_map from JSON payload" do
    get new_listing_wizard_path
    listing = Listing.order(created_at: :desc).first

    zones_json = [{ x: 42.5, y: 68.0, status: "surface", label: "Plancher", note: "" }].to_json
    patch save_step_listing_wizard_path(listing), params: {
      step: 2,
      listing: { draft_data: { rust_map: { silhouette_variant: "coupe", zones: zones_json } } }
    }, as: :turbo_stream

    listing.reload
    assert listing.rust_map.present?
    assert_equal "coupe", listing.rust_map.silhouette_variant
    assert_equal 1, listing.rust_map.zones.count
    assert_equal "surface", listing.rust_map.zones.first.status
    assert_equal 95, listing.rust_map.transparency_score # 100 - 5 (surface)
  end

  test "save_step persists originality score from step 3" do
    get new_listing_wizard_path
    listing = Listing.order(created_at: :desc).first

    patch save_step_listing_wizard_path(listing), params: {
      step: 3,
      listing: { draft_data: { originality: { matching_numbers: "1", original_interior: "1", original_paint_pct: "85" } } }
    }, as: :turbo_stream

    listing.reload
    assert listing.originality_score.present?
    assert listing.originality_score.matching_numbers
    assert listing.originality_score.original_interior
    assert_equal 85, listing.originality_score.original_paint_pct
    # 40 (matching) + 20 (interior) + 34 (85 * 0.4) = 94
    assert_equal 94, listing.originality_score.overall_score
  end

  test "save_step persists provenance events from step 4" do
    get new_listing_wizard_path
    listing = Listing.order(created_at: :desc).first

    patch save_step_listing_wizard_path(listing), params: {
      step: 4,
      listing: { draft_data: { provenance_events: [
        { event_year: "1989", event_type: "purchase", label: "Livraison neuve" },
        { event_year: "2012", event_type: "restoration", label: "Restauration" }
      ] } }
    }, as: :turbo_stream

    assert_equal 2, listing.reload.provenance_events.count
    assert_equal "Livraison neuve", listing.provenance_events.first.label
  end

  test "publish rejects when not publishable" do
    get new_listing_wizard_path
    listing = Listing.order(created_at: :desc).first

    patch publish_listing_wizard_path(listing)
    assert_redirected_to edit_listing_wizard_path(listing)
    assert_equal "draft", listing.reload.status
  end

  test "publish succeeds when listing has vehicle + photos + rust_map" do
    get new_listing_wizard_path
    listing = Listing.order(created_at: :desc).first

    # Attach a minimal photo and build rust_map so publishable? returns true
    listing.photos.attach(
      io: StringIO.new("fake-image-bytes"),
      filename: "cover.jpg",
      content_type: "image/jpeg"
    )
    listing.create_rust_map!(silhouette_variant: "sedan")
    listing.update!(draft_data: { "vehicle" => { "make" => "Citroën", "model" => "BX GTi 16V", "year" => 1989, "price" => 18500 } })

    patch publish_listing_wizard_path(listing)
    listing.reload
    assert_equal "active", listing.status
    assert_not_nil listing.published_at
    assert_redirected_to listing_path(listing)
  end

  test "non-owner cannot edit another user's draft" do
    get new_listing_wizard_path
    listing = Listing.order(created_at: :desc).first

    sign_out @user
    sign_in users(:two)

    get edit_listing_wizard_path(listing)
    assert_response :not_found # find raises RecordNotFound when scoped to current_user
  rescue ActiveRecord::RecordNotFound
    # acceptable : protection fine par scope current_user.listings
    assert true
  end
end
