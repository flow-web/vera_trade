module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    
    layout 'admin'
    
    private
    
    def require_admin
      unless current_user&.admin?
        flash[:alert] = "Vous n'avez pas les droits d'accès à cette section."
        redirect_to root_path
      end
    end
  end
end 