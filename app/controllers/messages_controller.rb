class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipient, only: [:show, :create]
  
  def index
    @users = current_user.other_users
  end

  def show
    @messages = Message.between(current_user.id, @recipient.id)
    @message = Message.new
    @current_user_id = current_user.id
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @message = Message.new(message_params)
    @message.sender = current_user
    @message.recipient = @recipient
    @message.current_user_id = current_user.id
    
    respond_to do |format|
      if @message.save
        format.turbo_stream
        format.html { redirect_to conversation_path(@recipient) }
      else
        format.html { render :show, status: :unprocessable_entity }
      end
    end
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
