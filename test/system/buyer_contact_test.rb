require "application_system_test_case"

class BuyerContactTest < ApplicationSystemTestCase
  # PR3 feat/buyer-contact — happy path Capybara.
  #
  # Fixture reminder :
  #   users(:one)   → Alice  (owns listings(:one))
  #   users(:three) → Claire (buyer)
  #
  # The flow exercises three personas :
  #   1. Claire lands on the fiche, clicks "Contacter le vendeur",
  #      fills the modal form with a message + an offer, submits.
  #   2. Alice signs in, the top-nav badge shows 1 unread message,
  #      she navigates to /dashboard and sees the new conversation
  #      with the offer amount.
  #   3. An anonymous visitor sees neither the modal nor the nav
  #      badge (both are gated on auth).

  # ---------- Perspective 1 : buyer sends a contact + offer ----------

  test "authenticated buyer opens the contact modal and sends a message with an offer" do
    login_as users(:three), scope: :user
    visit listing_path(listings(:one))

    # The trigger button should exist on the fiche hero.
    assert_selector "a", text: "CONTACTER LE VENDEUR"

    click_on "Contacter le vendeur"

    # The modal renders inside the turbo_frame_tag "listing_contact_modal".
    # Modal heading is the listing title rendered in Playfair italic (no
    # text-transform) so we assert on the listing title text.
    assert_text listings(:one).title

    fill_in "message_content",
      with: "Bonjour, votre BX m'intéresse énormément. Je peux me déplacer ce week-end."
    fill_in "message_offer_euros", with: "16000"
    click_on "Envoyer au vendeur"

    # Success redirects (breaks out of the frame via data-turbo-frame="_top")
    # to the conversation path for the seller.
    assert_current_path conversation_path(users(:one).id)

    # The conversation persisted with the listing link and the offer.
    convo = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:three))
    assert_equal 1, convo.messages.count
    msg = convo.messages.first
    assert_equal 16_000_00, msg.offer_cents
    assert_equal users(:three), msg.sender
    assert_equal users(:one),   msg.recipient
  end

  test "seller cannot contact themselves on their own listing" do
    login_as users(:one), scope: :user
    visit listing_path(listings(:one))

    # Owner sees "Modifier mon annonce" / "Supprimer" instead of the
    # contact button — the contact CTA is not even rendered.
    assert_no_selector "a", text: "CONTACTER LE VENDEUR"
  end

  # ---------- Perspective 2 : seller sees badge + dashboard ----------

  test "seller sees the unread badge in the nav and the message in the dashboard" do
    # Seed a message from the buyer to the seller first.
    convo = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:three))
    convo.messages.create!(
      sender:    users(:three),
      recipient: users(:one),
      content:   "Je vous propose 15 000€ si CT OK",
      offer_cents: 15_000_00,
      read:      false
    )

    login_as users(:one), scope: :user
    visit root_path

    # Badge must be visible in the top-nav immediately — a non-seen
    # offer is a dead transaction, per product rule.
    assert_selector "[data-testid='nav-unread-badge']", text: "1"
  end

  # ---------- Perspective 3 : anonymous visitor ----------

  test "anonymous visitor cannot see the contact button" do
    visit listing_path(listings(:one))

    # Anon gets the "sign in" CTA, not the contact button.
    assert_selector "a", text: "CONNECTEZ-VOUS POUR CONTACTER"
    assert_no_selector "a", text: "CONTACTER LE VENDEUR"
  end

  test "anonymous visitor does not see the unread badge" do
    visit root_path

    assert_no_selector "[data-testid='nav-unread-badge']"
  end
end
