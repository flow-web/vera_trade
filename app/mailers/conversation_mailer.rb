class ConversationMailer < ApplicationMailer
  # Notifies the recipient that a new message has landed in their inbox.
  # Called via Message#notify_recipient_by_email after_create_commit.
  #
  # Usage:
  #   ConversationMailer.new_message(message).deliver_later
  def new_message(message)
    @message      = message
    @sender       = message.sender
    @recipient    = message.recipient
    @conversation = message.conversation
    @listing      = @conversation&.listing

    @conversation_url = conversation_url(user_id: @sender.id)

    subject = if @listing
      "#{@sender.display_name} vous a contacté — #{@listing.title}"
    else
      "Nouveau message de #{@sender.display_name}"
    end

    mail(to: @recipient.email, subject: subject)
  end
end
