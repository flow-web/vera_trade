class KycController < ApplicationController
  before_action :authenticate_user!

  def show
    @documents = current_user.kyc_documents.order(created_at: :desc)
    @missing = current_user.kyc_missing_documents
  end

  def create
    @document = current_user.kyc_documents.build(kyc_params)

    if @document.save
      current_user.update!(kyc_status: "pending") unless current_user.kyc_verified?
      redirect_to kyc_path, notice: "Document envoyé. Vérification en cours."
    else
      @documents = current_user.kyc_documents.order(created_at: :desc)
      @missing = current_user.kyc_missing_documents
      render :show, status: :unprocessable_entity
    end
  end

  private

  def kyc_params
    params.require(:kyc_document).permit(:document_type, :file)
  end
end
