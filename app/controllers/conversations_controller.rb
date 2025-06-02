class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]

  def show
    # Ensure user has access to this conversation
    unless [@conversation.user, @conversation.other_user].include?(current_user)
      redirect_to messages_path, alert: "Vous n'êtes pas autorisé à accéder à cette conversation"
      return
    end
    
    @messages = @conversation.messages
                             .includes(:sender, :recipient, attachments_attachments: :blob)
                             .order(created_at: :asc)
    
    @message = Message.new
    @message_templates = current_user.message_templates.recent.limit(5)
    @video_call = VideoCall.new
    
    # Mark messages as read
    @conversation.messages.where(recipient: current_user, read: false).find_each(&:mark_as_read!)
    
    # Update conversation activity
    @conversation.update_activity!
    
    @other_participant = @conversation.other_participant(current_user)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
end
