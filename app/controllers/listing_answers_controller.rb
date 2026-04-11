class ListingAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing_and_question
  before_action :require_listing_owner

  def create
    if @question.answer.present?
      redirect_to listing_path(@listing), alert: "Cette question a déjà une réponse."
      return
    end

    @answer = @question.build_answer(answer_params)
    @answer.user = current_user

    if @answer.save
      respond_to do |format|
        format.html { redirect_to listing_path(@listing), notice: "Réponse publiée." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html do
          redirect_to listing_path(@listing), alert: @answer.errors.full_messages.to_sentence
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "listing_question_#{@question.id}",
            partial: "listings/listing_question",
            locals: { question: @question, listing: @listing, current_user: current_user, answer_errors: @answer.errors }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_listing_and_question
    @listing = Listing.find_by(slug: params[:listing_id]) || Listing.find(params[:listing_id])
    @question = @listing.listing_questions.find(params[:listing_question_id])
  end

  def require_listing_owner
    return if @listing.user_id == current_user.id

    redirect_to listing_path(@listing),
      alert: "Seul le vendeur peut répondre aux questions de cette annonce."
  end

  def answer_params
    params.require(:listing_answer).permit(:body)
  end
end
