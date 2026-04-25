class NotificationMailer < ApplicationMailer
  include ActionView::Helpers::NumberHelper

  def new_question(question)
    @question = question
    @listing  = question.listing
    @asker    = question.user
    @seller   = @listing.user
    @listing_url = listing_url(@listing)

    mail(
      to: @seller.email,
      subject: "Nouvelle question sur #{@listing.title}"
    )
  end

  def new_answer(answer)
    @answer   = answer
    @question = answer.listing_question
    @listing  = @question.listing
    @seller   = answer.user
    @asker    = @question.user
    @listing_url = listing_url(@listing)

    mail(
      to: @asker.email,
      subject: "#{@seller.display_name} a répondu à votre question — #{@listing.title}"
    )
  end

  def new_bid(bid)
    @bid     = bid
    @auction = bid.auction
    @listing = @auction.listing
    @bidder  = bid.bidder
    @seller  = @listing.user
    @auction_url = auction_url(@auction)

    mail(
      to: @seller.email,
      subject: "Nouvelle enchère : #{number_to_currency(@bid.amount, unit: '€', format: '%n %u')} — #{@listing.title}"
    )
  end

  def outbid(bid, outbid_user)
    @bid         = bid
    @auction     = bid.auction
    @listing     = @auction.listing
    @bidder      = bid.bidder
    @outbid_user = outbid_user
    @auction_url = auction_url(@auction)

    mail(
      to: @outbid_user.email,
      subject: "Vous avez été surenchéri — #{@listing.title}"
    )
  end

  def auction_ending_soon(auction, watcher)
    @auction     = auction
    @listing     = auction.listing
    @watcher     = watcher
    @auction_url = auction_url(@auction)

    mail(
      to: @watcher.email,
      subject: "Enchère bientôt terminée — #{@listing.title}"
    )
  end
end
