class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:index, :create, :show]
  before_action :set_message, only: [:mark_as_read, :add_reaction, :remove_reaction]

  def index
    @conversations = current_user.active_conversations.includes(:messages, :listing, :user, :other_user)
    @archived_conversations = current_user.archived_conversations.includes(:messages, :listing, :user, :other_user)
    @message_templates = current_user.message_templates.by_category(params[:template_category] || 'custom').recent
  end

  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages.includes(:sender, :recipient, attachments_attachments: :blob).order(created_at: :asc)
    @message = Message.new
    @message_templates = current_user.message_templates.recent.limit(5)
    
    # Mark messages as read
    @conversation.messages.where(recipient: current_user, read: false).find_each(&:mark_as_read!)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @message = Message.new(message_params)
    @message.sender = current_user
    
    # Determine recipient and conversation
    if params[:recipient_id].present?
      @message.recipient = User.find(params[:recipient_id])
      @conversation = Conversation.find_or_create_between(current_user, @message.recipient, params[:listing_id].present? ? Listing.find(params[:listing_id]) : nil)
      @message.conversation = @conversation
    elsif @conversation
      @message.recipient = @conversation.other_participant(current_user)
      @message.conversation = @conversation
    end
    
    # Handle attachments
    if params[:message].present? && params[:message][:attachments].present?
      @message.message_type = determine_message_type(params[:message][:attachments])
      @message.attachments.attach(params[:message][:attachments])
    end
    
    # Handle quick reply template
    if params[:template_id].present?
      template = current_user.message_templates.find(params[:template_id])
      @message.content = template.content
      @message.message_type = 'quick_reply'
    end

    if @message.save
      respond_to do |format|
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.append("message-list", partial: "messages/message", locals: { message: @message, current_user: current_user }),
            turbo_stream.replace("message-form", partial: "messages/form", locals: { message: Message.new, conversation: @conversation })
          ]
        }
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message-form", partial: "messages/form", locals: { message: @message, conversation: @conversation }) }
        format.html { render :show, status: :unprocessable_entity }
      end
    end
  end

  def mark_as_read
    @message.mark_as_read! if @message.recipient == current_user
    
    respond_to do |format|
      format.turbo_stream { head :ok }
      format.json { render json: { status: 'read' } }
    end
  end

  def add_reaction
    emoji = params[:emoji]
    @message.add_reaction(current_user, emoji)
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace("message-reactions-#{@message.id}", 
               partial: "messages/reactions", locals: { message: @message, current_user: current_user })
      }
      format.json { render json: { status: 'added', reactions: @message.parse_reactions } }
    end
  end

  def remove_reaction
    emoji = params[:emoji]
    @message.remove_reaction(current_user, emoji)
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace("message-reactions-#{@message.id}", 
               partial: "messages/reactions", locals: { message: @message, current_user: current_user })
      }
      format.json { render json: { status: 'removed', reactions: @message.parse_reactions } }
    end
  end

  def archive_conversation
    @conversation = Conversation.find(params[:conversation_id])
    @conversation.archive_for!(current_user)
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: turbo_stream.remove("conversation-#{@conversation.id}")
      }
      format.html { redirect_to messages_path, notice: 'Conversation archivée' }
    end
  end

  def unarchive_conversation
    @conversation = Conversation.find(params[:conversation_id])
    @conversation.unarchive_for!(current_user)
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: turbo_stream.remove("archived-conversation-#{@conversation.id}")
      }
      format.html { redirect_to messages_path, notice: 'Conversation restaurée' }
    end
  end

  def templates
    @templates = current_user.message_templates.by_category(params[:category] || 'custom').recent
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace("template-list", 
               partial: "messages/template_list", locals: { templates: @templates })
      }
      format.json { render json: @templates }
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id]) if params[:conversation_id].present?
  end

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    return {} unless params[:message].present?
    params.require(:message).permit(:content, :message_type, attachments: [])
  end

  def determine_message_type(attachments)
    return 'text' unless attachments.present?
    
    first_attachment = attachments.first
    content_type = first_attachment.content_type
    
    case content_type
    when /^image\//
      'image'
    when /^video\//
      'video'
    when /^audio\//
      'audio'
    else
      'document'
    end
  end
end
