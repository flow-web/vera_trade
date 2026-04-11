class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @conversations = all_conversations
    @current_conversation = @conversations.first
  end

  def show
    @conversations = all_conversations
    @current_conversation = all_conversations.find_by(user_id: params[:user_id], other_user_id: current_user.id) ||
                            all_conversations.find_by(user_id: current_user.id, other_user_id: params[:user_id])

    return head :not_found unless @current_conversation

    @recipient = @current_conversation.user_id == current_user.id ? @current_conversation.other_user : @current_conversation.user
    @messages = Message.between(current_user.id, @recipient.id)
    @message = Message.new
    @current_user_id = current_user.id

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @conversation = Conversation.find_or_create_by!(user_id: current_user.id, other_user_id: params[:user_id])
    redirect_to conversation_path(@conversation.other_user_id)
  end

  private

  def all_conversations
    Conversation.where(user_id: current_user.id).or(Conversation.where(other_user_id: current_user.id))
                .includes(:user, :other_user).order(updated_at: :desc)
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
