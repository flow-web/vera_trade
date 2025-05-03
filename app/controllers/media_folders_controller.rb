class MediaFoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:create]
  before_action :set_media_folder, only: [:destroy]
  before_action :ensure_owner, only: [:create, :destroy]

  def create
    @media_folder = @listing.media_folders.new(media_folder_params)
    
    respond_to do |format|
      if @media_folder.save
        format.html { redirect_to @listing, notice: 'Dossier créé avec succès.' }
        format.json { render json: { success: true, media_folder: @media_folder }, status: :created }
      else
        format.html { redirect_to @listing, alert: "Erreur lors de la création du dossier: #{@media_folder.errors.full_messages.join(', ')}" }
        format.json { render json: { success: false, errors: @media_folder.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    listing = @media_folder.listing
    
    respond_to do |format|
      if @media_folder.destroy
        format.html { redirect_to listing, notice: 'Dossier supprimé avec succès.' }
        format.json { render json: { success: true }, status: :ok }
      else
        format.html { redirect_to listing, alert: 'Erreur lors de la suppression du dossier.' }
        format.json { render json: { success: false }, status: :unprocessable_entity }
      end
    end
  end

  private
  
  def set_listing
    @listing = Listing.find(params[:listing_id])
  end
  
  def set_media_folder
    @media_folder = MediaFolder.find(params[:id])
  end
  
  def ensure_owner
    if action_name == 'create'
      unless @listing.user == current_user
        respond_to do |format|
          format.html { redirect_to listings_path, alert: 'Vous n\'êtes pas autorisé à créer des dossiers pour cette annonce.' }
          format.json { render json: { success: false, error: 'Unauthorized' }, status: :unauthorized }
        end
      end
    else
      unless @media_folder.listing.user == current_user
        respond_to do |format|
          format.html { redirect_to listings_path, alert: 'Vous n\'êtes pas autorisé à supprimer ce dossier.' }
          format.json { render json: { success: false, error: 'Unauthorized' }, status: :unauthorized }
        end
      end
    end
  end
  
  def media_folder_params
    params.require(:media_folder).permit(:name, :description, :private)
  end
end
