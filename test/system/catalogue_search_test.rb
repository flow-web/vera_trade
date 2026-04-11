require "application_system_test_case"

class CatalogueSearchTest < ApplicationSystemTestCase
  # PR1 catalogue-search — happy path Capybara.
  #
  # Scénario : un visiteur anonyme arrive sur /listings avec 3 annonces
  # contrastées en DB. Il cherche "Citroën" et filtre sur segment
  # Youngtimer. Il doit voir la Citroën BX mais pas le Twingo Récent.
  #
  # Ce test valide end-to-end :
  #   - le form GET soumet les bons params
  #   - pg_search_scope match via weighted rank
  #   - by_segment filtre sur year range
  #   - le turbo_frame_tag "listings_grid" re-render le bloc résultats
  #   - la vue affiche les titres des listings
  #
  # Fixtures utilisées (chargées automatiquement via fixtures :all) :
  #   :one   Citroën BX GTi 16V 1989   → Youngtimer
  #   :two   Peugeot 205 GTI 1.9 1991  → Youngtimer
  #   :three Renault Twingo III 2020   → Récent

  test "visitor lands on catalogue and sees all active listings" do
    visit listings_path

    assert_selector "h1", text: "Le catalogue."
    assert_text "Citroën BX GTi 16V de 1989"
    assert_text "Peugeot 205 GTI 1.9 de 1991"
    assert_text "Renault Twingo III de 2020"
  end

  test "visitor searches 'Citroën' and only the Citroën listing is visible" do
    visit listings_path

    fill_in "query", with: "Citroën"
    click_on "Filtrer"

    assert_text "Citroën BX GTi 16V de 1989"
    assert_no_text "Peugeot 205 GTI 1.9 de 1991"
    assert_no_text "Renault Twingo III de 2020"
  end

  test "visitor filters by segment Youngtimer and excludes the recent Twingo" do
    visit listings_path

    select "Youngtimer", from: "segment"
    click_on "Filtrer"

    assert_text "Citroën BX GTi 16V de 1989"
    assert_text "Peugeot 205 GTI 1.9 de 1991"
    assert_no_text "Renault Twingo III de 2020"
  end

  test "visitor combines search and segment filter" do
    # Query "Peugeot" + segment Youngtimer → only the 205 GTI should match.
    visit listings_path

    fill_in "query", with: "Peugeot"
    select "Youngtimer", from: "segment"
    click_on "Filtrer"

    assert_text "Peugeot 205 GTI 1.9 de 1991"
    assert_no_text "Citroën BX GTi 16V de 1989"
    assert_no_text "Renault Twingo III de 2020"
  end

  test "visitor with zero matches sees the editorial empty state" do
    visit listings_path

    fill_in "query", with: "zzzzz_no_match_ever"
    click_on "Filtrer"

    assert_text "Aucune voiture ne correspond à votre recherche."
    assert_no_text "Citroën BX GTi 16V de 1989"
  end

  test "visitor clicks Réinitialiser to clear all filters" do
    visit listings_path(query: "Citroën")

    # Filtered state: only Citroën visible
    assert_text "Citroën BX GTi 16V de 1989"
    assert_no_text "Renault Twingo III de 2020"

    click_on "Réinitialiser"

    # Cleared state: all 3 visible again
    assert_text "Citroën BX GTi 16V de 1989"
    assert_text "Peugeot 205 GTI 1.9 de 1991"
    assert_text "Renault Twingo III de 2020"
  end
end
