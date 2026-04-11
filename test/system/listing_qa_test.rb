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
  #   2. Authenticated non-owner (Bob) posts a new question
  #   3. Authenticated owner (Alice) answers the new question
  #   4. The new Q+A becomes visible to anonymous visitors

  def sign_in_as(user)
    visit new_user_session_path
    fill_in "user_email",    with: user.email
    fill_in "user_password", with: "password123"
    click_on "Se connecter"
  end

  # ---------- Perspective 1 : anonymous visitor ----------

  test "anonymous visitor sees existing Q+A publicly on the fiche annonce" do
    visit listing_path(listings(:one))

    assert_text "Questions & Réponses"
    assert_text "Est-ce que la peinture est d'origine"   # listing_questions(:one).body
    assert_text "Non, le capot et l'aile arrière droite" # listing_answers(:one).body
  end

  test "anonymous visitor cannot see the question form and is prompted to sign in" do
    visit listing_path(listings(:one))

    assert_text "Connectez-vous pour poser une question au vendeur."
    assert_no_selector "textarea[name='listing_question[body]']"
  end

  # ---------- Perspective 2 : authenticated buyer asks a question ----------

  test "authenticated buyer (non-owner) can post a new question" do
    sign_in_as users(:three) # Claire, pas propriétaire de listings(:one)
    visit listing_path(listings(:one))

    fill_in "listing_question_body",
      with: "Quelle est l'origine exacte des ressorts de suspension ?"
    click_on "Envoyer la question"

    assert_text "Quelle est l'origine exacte des ressorts"
    assert_text "En attente de réponse du vendeur"
  end

  test "listing owner cannot post a question on their own listing" do
    sign_in_as users(:one) # Alice, propriétaire de listings(:one)
    visit listing_path(listings(:one))

    # Form is hidden for the owner — they can only answer, not ask.
    assert_no_selector "textarea[name='listing_question[body]']"
  end

  # ---------- Perspective 3 : owner answers the question ----------

  test "listing owner sees the answer form and can publish an answer" do
    # First, seed a new unanswered question (not the fixture one, which
    # already has an answer).
    new_q = listings(:one).listing_questions.create!(
      user: users(:three),
      body: "Y a-t-il un historique complet de révision ?"
    )

    sign_in_as users(:one) # Alice, the seller
    visit listing_path(listings(:one))

    # The answer form should be visible inline on the new question.
    assert_text "Y a-t-il un historique complet de révision ?"

    within "##{ActionView::RecordIdentifier.dom_id(new_q)}" do
      fill_in "listing_answer[body]",
        with: "Oui, carnet d'entretien complet disponible en mains propres."
      click_on "Publier la réponse"
    end

    assert_text "Oui, carnet d'entretien complet disponible en mains propres."
    assert_text "Réponse du vendeur"
  end

  # ---------- Perspective 4 : full loop visible anonymously ----------

  test "new Q+A becomes visible to anonymous visitors after the full flow" do
    # Step 1 — buyer asks
    sign_in_as users(:three)
    visit listing_path(listings(:one))
    fill_in "listing_question_body",
      with: "Le véhicule a-t-il déjà participé à des rallyes historiques ?"
    click_on "Envoyer la question"
    assert_text "Le véhicule a-t-il déjà participé à des rallyes historiques ?"

    # Step 2 — sign out, sign in as seller, answer
    click_on "Déconnexion" rescue visit destroy_user_session_path
    sign_in_as users(:one)
    visit listing_path(listings(:one))

    # The first matching textarea is for the new question (fixture one is
    # already answered).
    new_q = listings(:one).listing_questions.find_by!(
      body: "Le véhicule a-t-il déjà participé à des rallyes historiques ?"
    )
    within "##{ActionView::RecordIdentifier.dom_id(new_q)}" do
      fill_in "listing_answer[body]",
        with: "Oui, Tour Auto 2019 et Rallye des Princesses 2021."
      click_on "Publier la réponse"
    end

    # Step 3 — sign out, anonymous visit, verify public visibility
    click_on "Déconnexion" rescue visit destroy_user_session_path
    visit listing_path(listings(:one))

    assert_text "Le véhicule a-t-il déjà participé à des rallyes historiques ?"
    assert_text "Oui, Tour Auto 2019 et Rallye des Princesses 2021."
  end
end
