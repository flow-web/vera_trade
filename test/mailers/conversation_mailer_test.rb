require "test_helper"

class ConversationMailerTest < ActionMailer::TestCase
  # D2 / chore/prod-urls-and-mailer — guards the contract that new
  # messages trigger an email notification to the recipient.

  setup do
    @message = messages(:one)
    @mail    = ConversationMailer.new_message(@message)
  end

  test "new_message is sent to the recipient" do
    assert_equal [ @message.recipient.email ], @mail.to
  end

  test "new_message is sent from the platform address" do
    assert_equal [ ApplicationMailer.default[:from] ], @mail.from
  end

  test "new_message subject includes sender name" do
    assert_includes @mail.subject, @message.sender.display_name
  end

  test "new_message subject includes listing title when conversation has a listing" do
    assert @message.conversation.listing.present?, "fixture must have a listing"
    assert_includes @mail.subject, @message.conversation.listing.title
  end

  test "new_message HTML body includes message preview" do
    assert_includes @mail.html_part.body.decoded, @message.content
  end

  test "new_message HTML body includes a link to the conversation" do
    assert_includes @mail.html_part.body.decoded, "conversations/#{@message.sender_id}"
  end

  test "new_message text body includes message content" do
    assert_includes @mail.text_part.body.decoded, @message.content
  end

  test "new_message is enqueued when a message is created" do
    buyer     = users(:two)   # Bob — NOT the listing owner
    seller    = users(:one)   # Alice — owns listings(:one)
    listing   = listings(:one)
    convo     = Conversation.find_or_create_for(listing: listing, buyer: buyer)

    assert_enqueued_email_with ConversationMailer, :new_message do
      Message.create!(
        content:       "Test notification",
        sender:        buyer,
        recipient:     seller,
        conversation:  convo
      )
    end
  end
end
