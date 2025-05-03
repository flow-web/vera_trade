class MediaItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:create]
  before_action :set_media_item, only: [:destroy]
  before_action :ensure_owner, only: [:create, :destroy]

  def create
    content_type = detect_content_type(params[:media_item][:media])
    private = params[:media_item][:private] == "1"
    folder_id = params[:media_item][:media_folder_id].presence
    
    @media_item = @listing.media_items.new(
      title: params[:media_item][:title].presence || "Sans titre",
      context: params[:media_item][:context],
      content_type: content_type,
      private: private,
      media_folder_id: folder_id
    )
    
    @media_item.media.attach(params[:media_item][:media])
    
    respond_to do |format|
      if @media_item.save
        format.html { redirect_to @listing, notice: 'Média ajouté avec succès.' }
        format.json { render json: { success: true, media_item: @media_item.as_json(include: :media) }, status: :created }
      else
        format.html { redirect_to @listing, alert: "Erreur lors de l'ajout du média: #{@media_item.errors.full_messages.join(', ')}" }
        format.json { render json: { success: false, errors: @media_item.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    listing = @media_item.listing
    
    respond_to do |format|
      if @media_item.destroy
        format.html { redirect_to listing, notice: 'Média supprimé avec succès.' }
        format.json { render json: { success: true }, status: :ok }
      else
        format.html { redirect_to listing, alert: 'Erreur lors de la suppression du média.' }
        format.json { render json: { success: false }, status: :unprocessable_entity }
      end
    end
  end

  private
  
  def set_listing
    @listing = Listing.find(params[:listing_id])
  end
  
  def set_media_item
    @media_item = MediaItem.find(params[:id])
  end
  
  def ensure_owner
    if action_name == 'create'
      unless @listing.user == current_user
        respond_to do |format|
          format.html { redirect_to listings_path, alert: 'Vous n\'êtes pas autorisé à ajouter des médias à cette annonce.' }
          format.json { render json: { success: false, error: 'Unauthorized' }, status: :unauthorized }
        end
      end
    else
      unless @media_item.listing.user == current_user
        respond_to do |format|
          format.html { redirect_to listings_path, alert: 'Vous n\'êtes pas autorisé à supprimer ce média.' }
          format.json { render json: { success: false, error: 'Unauthorized' }, status: :unauthorized }
        end
      end
    end
  end
  
  def detect_content_type(upload)
    return "document" if upload.content_type == "application/pdf"
    return "video" if upload.content_type.start_with?('video/')
    return "image" if upload.content_type.start_with?('image/')
    
    "unknown"
  end
end
