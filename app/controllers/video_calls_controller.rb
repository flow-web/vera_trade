class VideoCallsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_video_call, only: [:show, :update, :destroy, :join, :leave]
  before_action :set_conversation, only: [:create]

  def index
    @upcoming_calls = current_user.all_conversations
                                 .joins(:video_calls)
                                 .merge(VideoCall.upcoming)
                                 .includes(:video_calls, :user, :other_user, :listing)
    
    @past_calls = current_user.all_conversations
                             .joins(:video_calls)
                             .merge(VideoCall.past)
                             .includes(:video_calls, :user, :other_user, :listing)
                             .limit(10)
  end

  def show
    # Check if user can access this call
    unless @video_call.can_join?(current_user)
      redirect_to messages_path, alert: "Vous n'êtes pas autorisé à accéder à cet appel"
      return
    end
    
    @conversation = @video_call.conversation
    @other_participant = @video_call.other_participant(current_user)
    
    respond_to do |format|
      format.html
      format.json { render json: { room_id: @video_call.room_id, status: @video_call.status } }
    end
  end

  def create
    @video_call = @conversation.video_calls.build(video_call_params)
    
    if @video_call.save
      # Send notification to other participant
      other_participant = @conversation.other_participant(current_user)
      
      # Create system message about video call
      system_message = @conversation.messages.create!(
        sender: current_user,
        recipient: other_participant,
        content: "Proposition d'appel vidéo pour le #{@video_call.scheduled_at.strftime('%d/%m/%Y à %H:%M')}",
        message_type: 'system'
      )
      
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.append("message-list", partial: "messages/message", locals: { message: system_message, current_user: current_user }),
            turbo_stream.replace("video-call-form", partial: "video_calls/form", locals: { video_call: VideoCall.new, conversation: @conversation })
          ]
        }
        format.html { redirect_to conversation_path(@conversation), notice: "Appel vidéo planifié" }
        format.json { render json: @video_call, status: :created }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("video-call-form", partial: "video_calls/form", locals: { video_call: @video_call, conversation: @conversation }) }
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @video_call.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    case params[:action_type]
    when 'accept'
      @video_call.update!(status: 'ringing')
    when 'reject'
      @video_call.reject!
    when 'start'
      @video_call.start!
    when 'end'
      @video_call.end!
    when 'cancel'
      @video_call.cancel!
    end
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace("video-call-status-#{@video_call.id}", 
               partial: "video_calls/status", locals: { video_call: @video_call })
      }
      format.html { redirect_to @video_call }
      format.json { render json: { status: @video_call.status } }
    end
  end

  def destroy
    @video_call.cancel!
    
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("video-call-#{@video_call.id}") }
      format.html { redirect_to video_calls_path, notice: "Appel vidéo annulé" }
    end
  end

  def join
    unless @video_call.can_join?(current_user)
      redirect_to messages_path, alert: "Vous ne pouvez pas rejoindre cet appel"
      return
    end
    
    # Start the call if it's the first participant joining
    @video_call.start! if @video_call.scheduled?
    
    respond_to do |format|
      format.html { render :show }
      format.json { render json: { room_id: @video_call.room_id, status: @video_call.status } }
    end
  end

  def leave
    if @video_call.active?
      @video_call.end!
    end
    
    respond_to do |format|
      format.html { redirect_to conversation_path(@video_call.conversation), notice: "Vous avez quitté l'appel" }
      format.json { render json: { status: 'left' } }
    end
  end

  private

  def set_video_call
    @video_call = VideoCall.find(params[:id])
  end

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def video_call_params
    params.require(:video_call).permit(:scheduled_at)
  end
end
