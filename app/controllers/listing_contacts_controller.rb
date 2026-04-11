class ListingContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing
  before_action :forbid_owner_self_contact

  # GET /listings/:listing_id/contact/new
  #
  # Renders the modal form. The top-level wrapper is a turbo_frame_tag
  # named "listing_contact_modal" so clicking the trigger link on the
  # fiche annonce swaps this view into the empty frame container that
  # lives at the bottom of show.html.erb.
  def new
    @message = Message.new
  end

  # POST /listings/:listing_id/contact
  #
  # Finds-or-creates the per-(listing, buyer) conversation and appends
  # the first message. On success the form breaks out of the Turbo Frame
  # and navigates to the conversation show page (data-turbo-frame="_top"
  # on the form element), matching the common "open conversation" UX.
  def create
    @conversation = Conversation.find_or_create_for(listing: @listing, buyer: current_user)
    @message = @conversation.messages.build(message_params)
    @message.sender    = current_user
    @message.recipient = @listing.user

    if @message.save
      redirect_to conversation_path(@listing.user),
        notice: "Message envoyé au vendeur."
    else
      # The form has turbo: false (see new.html.erb), so this is a classic
      # full-page navigation. Render :new would show the modal view as a
      # standalone page (no listing context). Redirecting back to the
      # listing with the validation errors flashed gives a coherent UX.
      redirect_to listing_path(@listing),
        alert: @message.errors.full_messages.to_sentence
    end
  rescue ArgumentError => e
    redirect_to listing_path(@listing), alert: e.message
  end

  private

  def set_listing
    @listing = Listing.find_by(slug: params[:listing_id]) || Listing.find(params[:listing_id])
  end

  def forbid_owner_self_contact
    return unless @listing.user_id == current_user.id

    redirect_to listing_path(@listing),
      alert: "Vous ne pouvez pas vous contacter vous-même."
  end

  # The form exposes an "offer_euros" field for UX (people type "15000",
  # not "1500000"). We convert to cents at the controller boundary so
  # the model stores integer cents exclusively.
  def message_params
    permitted = params.require(:message).permit(:content, :offer_euros)
    offer_euros = permitted.delete(:offer_euros)
    permitted[:offer_cents] = (offer_euros.to_f * 100).to_i if offer_euros.present?
    permitted
  end
end
