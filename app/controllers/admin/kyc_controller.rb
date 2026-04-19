module Admin
  class KycController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    before_action :set_document, only: [:show, :approve, :reject]

    def index
      @pending = KycDocument.pending.includes(:user).order(created_at: :asc)
      @recent = KycDocument.where.not(status: "pending").includes(:user, :reviewer).order(reviewed_at: :desc).limit(20)
    end

    def show
    end

    def approve
      @document.approve!(current_user)
      redirect_to admin_kyc_index_path, notice: "Document approuvé pour #{@document.user.display_name}"
    end

    def reject
      reason = params[:rejection_reason].presence || "Document non conforme"
      @document.reject!(current_user, reason: reason)
      redirect_to admin_kyc_index_path, notice: "Document refusé pour #{@document.user.display_name}"
    end

    private

    def set_document
      @document = KycDocument.find(params[:id])
    end

    def require_admin!
      redirect_to root_path, alert: "Accès non autorisé" unless current_user.admin?
    end
  end
end
