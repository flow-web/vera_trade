require "application_system_test_case"

class ConversationMailerSystemTest < ApplicationSystemTestCase
  # D2 / chore/prod-urls-and-mailer — Capybara happy path.
  #
  # Verifies end-to-end that when a buyer sends a message through the
  # contact modal, a notification email is enqueued for the seller.
  #
  # Fixture roles:
  #   users(:one)   → Alice / seller  (owns listings(:one))
  #   users(:three) → Claire / buyer

  include ActiveJob::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "sending a message through the contact modal queues a notification email to the seller" do
    seller = users(:one)
    login_as users(:three), scope: :user
    visit listing_path(listings(:one))

    click_on "Contacter le vendeur"

    fill_in "message_content", with: "Bonjour, la voiture est-elle encore disponible ?"
    click_on "Envoyer au vendeur"

    # Success redirects to the conversation view.
    assert_current_path conversation_path(seller.id)

    # Drain the job queue: the MailDeliveryJob was enqueued during the
    # HTTP request above; running it populates ActionMailer::Base.deliveries.
    perform_enqueued_jobs

    email = ActionMailer::Base.deliveries.last
    assert_not_nil email, "A notification email must have been delivered to the seller"
    assert_includes email.to, seller.email
    assert_includes email.subject, listings(:one).title
  end
end
