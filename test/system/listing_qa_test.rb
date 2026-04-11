require "application_system_test_case"

class ListingQaTest < ApplicationSystemTestCase
  # PR2 feat/listing-qa — Capybara happy path.
  #
  # Fixture reminder :
  #   listings(:one).user     → users(:one)    (Alice, vendeuse)
  #   listing_questions(:one) → user: users(:two) (Bob, acheteur)
  #
  # The tests exercise three perspectives :
  #   1. Anonymous visitor reads the existing public Q+A on the fiche
  #   2. Authenticated non-owner (Bob / Claire) posts a new question
  #   3. Authenticated owner (Alice) answers the new question
  #   4. The new Q+A becomes visible to anonymous visitors after the flow
  #
  # Authentication uses Warden::Test::Helpers (configured in
  # ApplicationSystemTestCase) to skip the UI sign-in form — much faster
  # than driving the Devise session form via Capybara, and immune to
  # selector collisions with identically-labelled nav links.

  # ---------- Perspective 1 : anonymous visitor ----------

  test "anonymous visitor sees existing Q+A publicly on the fiche annonce" do
    visit listing_path(listings(:one))

    # The section header renders via .eyebrow CSS (text-transform:
    # uppercase) so we assert on the h2 title instead — it's in Playfair
    # italic with no transform, so it stays in its original case.
    assert_text "L'avis des autres collectionneurs."
    assert_text "Est-ce que la peinture est d'origine"
    assert_text "Non, le capot et l'aile arrière droite"
  end

  test "anonymous visitor cannot see the question form and is prompted to sign in" do
    visit listing_path(listings(:one))

    assert_text "Connectez-vous pour poser une question au vendeur."
    assert_no_selector "textarea[name='listing_question[body]']"
  end

  # ---------- Perspective 2 : authenticated buyer asks a question ----------

  test "authenticated buyer (non-owner) can post a new question" do
    login_as users(:three), scope: :user # Claire, pas propriétaire
    visit listing_path(listings(:one))

    fill_in "listing_question_body",
      with: "Quelle est l'origine exacte des ressorts de suspension ?"
    click_on "Envoyer la question"

    assert_text "Quelle est l'origine exacte des ressorts"
    # Rendered uppercase via `.uppercase` Tailwind class in _listing_question.html.erb.
    assert_text "EN ATTENTE DE RÉPONSE DU VENDEUR"
  end

  test "listing owner cannot post a question on their own listing" do
    login_as users(:one), scope: :user # Alice, propriétaire
    visit listing_path(listings(:one))

    # Form is hidden for the owner — they can only answer, not ask.
    assert_no_selector "textarea[name='listing_question[body]']"
  end

  # ---------- Perspective 3 : owner answers the question ----------

  test "listing owner sees the answer form and can publish an answer" do
    new_q = listings(:one).listing_questions.create!(
      user: users(:three),
      body: "Y a-t-il un historique complet de révision ?"
    )

    login_as users(:one), scope: :user # Alice, the seller
    visit listing_path(listings(:one))

    assert_text "Y a-t-il un historique complet de révision ?"

    within "##{ActionView::RecordIdentifier.dom_id(new_q)}" do
      fill_in "listing_answer[body]",
        with: "Oui, carnet d'entretien complet disponible en mains propres."
      click_on "Publier la réponse"
    end

    assert_text "Oui, carnet d'entretien complet disponible en mains propres."
    # Rendered uppercase via `.uppercase` Tailwind class.
    assert_text "RÉPONSE DU VENDEUR", exact: false
  end

  # ---------- Perspective 4 : full loop visible anonymously ----------

  test "new Q+A becomes visible to anonymous visitors after the full flow" do
    # Step 1 — buyer asks
    login_as users(:three), scope: :user
    visit listing_path(listings(:one))
    fill_in "listing_question_body",
      with: "Le véhicule a-t-il déjà participé à des rallyes historiques ?"
    click_on "Envoyer la question"
    assert_text "Le véhicule a-t-il déjà participé à des rallyes historiques ?"
    logout :user

    # Step 2 — sign in as seller, answer the new question
    login_as users(:one), scope: :user
    visit listing_path(listings(:one))

    new_q = listings(:one).listing_questions.find_by!(
      body: "Le véhicule a-t-il déjà participé à des rallyes historiques ?"
    )
    within "##{ActionView::RecordIdentifier.dom_id(new_q)}" do
      fill_in "listing_answer[body]",
        with: "Oui, Tour Auto 2019 et Rallye des Princesses 2021."
      click_on "Publier la réponse"
    end
    assert_text "Oui, Tour Auto 2019 et Rallye des Princesses 2021."
    logout :user

    # Step 3 — anonymous visit, verify public visibility
    visit listing_path(listings(:one))

    assert_text "Le véhicule a-t-il déjà participé à des rallyes historiques ?"
    assert_text "Oui, Tour Auto 2019 et Rallye des Princesses 2021."
  end
end
