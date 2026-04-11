class ListingQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing
  before_action :forbid_owner_self_question, only: [ :create ]

  def create
    if ListingQuestion.over_rate_limit?(user: current_user, listing: @listing)
      respond_to do |format|
        format.html do
          redirect_to listing_path(@listing),
            alert: "Vous avez atteint la limite de #{ListingQuestion::RATE_LIMIT_PER_DAY} questions par jour sur cette annonce."
        end
        format.turbo_stream do
          flash.now[:alert] = "Limite quotidienne atteinte (#{ListingQuestion::RATE_LIMIT_PER_DAY} questions)."
          render turbo_stream: turbo_stream.replace(
            "listing_question_form",
            partial: "listings/listing_question_form",
            locals: { listing: @listing, question: ListingQuestion.new(question_params), flash_alert: flash.now[:alert] }
          ), status: :unprocessable_entity
        end
      end
      return
    end

    @question = @listing.listing_questions.build(question_params)
    @question.user = current_user

    if @question.save
      respond_to do |format|
        format.html { redirect_to listing_path(@listing), notice: "Question envoyée." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html do
          redirect_to listing_path(@listing), alert: @question.errors.full_messages.to_sentence
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "listing_question_form",
            partial: "listings/listing_question_form",
            locals: { listing: @listing, question: @question }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_listing
    @listing = Listing.find_by(slug: params[:listing_id]) || Listing.find(params[:listing_id])
  end

  def forbid_owner_self_question
    return unless @listing.user_id == current_user.id

    redirect_to listing_path(@listing),
      alert: "Vous ne pouvez pas poser de question sur votre propre annonce."
  end

  def question_params
    params.require(:listing_question).permit(:body)
  end
end
