class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipient, only: [:show, :create]
  
  def index
    @conversations = current_user.conversations.includes(:other_user, :messages).order(updated_at: :desc)
    @current_conversation = @conversations.first
  end

  def show
    @conversations = current_user.conversations.includes(:other_user, :messages).order(updated_at: :desc)
    @current_conversation = current_user.conversations.find(params[:id])
    @messages = Message.between(current_user.id, @recipient.id)
    @message = Message.new
    @current_user_id = current_user.id
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @conversation = current_user.conversations.find_or_create_by(other_user_id: params[:user_id])
    redirect_to conversation_path(@conversation)
  end
  
  private
  
  def set_recipient
    user_id = params[:user_id] || params[:message]&.[](:user_id)
    @recipient = User.find(user_id) if user_id.present?
  end
  
  def message_params
    params.require(:message).permit(:content)
  end
end
