class MessageTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message_template, only: [:show, :update, :destroy]

  def index
    @message_templates = current_user.message_templates.by_category(params[:category] || 'custom').recent
    @new_template = MessageTemplate.new
    
    respond_to do |format|
      format.html
      format.json { render json: @message_templates }
    end
  end

  def create
    @message_template = current_user.message_templates.build(message_template_params)
    
    if @message_template.save
      respond_to do |format|
        format.html { redirect_to message_templates_path, notice: 'Modèle créé avec succès.' }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.append("template-list", 
                 partial: "message_templates/template", locals: { template: @message_template })
        }
        format.json { render json: @message_template, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :index, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace("new-template-form", 
                 partial: "message_templates/form", locals: { template: @message_template })
        }
        format.json { render json: @message_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @message_template.update(message_template_params)
      respond_to do |format|
        format.html { redirect_to message_templates_path, notice: 'Modèle mis à jour avec succès.' }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace("template-#{@message_template.id}", 
                 partial: "message_templates/template", locals: { template: @message_template })
        }
        format.json { render json: @message_template }
      end
    else
      respond_to do |format|
        format.html { render :index, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace("template-#{@message_template.id}", 
                 partial: "message_templates/edit_form", locals: { template: @message_template })
        }
        format.json { render json: @message_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @message_template.destroy
    
    respond_to do |format|
      format.html { redirect_to message_templates_path, notice: 'Modèle supprimé avec succès.' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("template-#{@message_template.id}") }
      format.json { head :no_content }
    end
  end

  private

  def set_message_template
    @message_template = current_user.message_templates.find(params[:id])
  end

  def message_template_params
    params.require(:message_template).permit(:title, :content, :category)
  end
end
