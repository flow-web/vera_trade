class RegistrationsController < Devise::RegistrationsController
  def create
    super do |user|
      if session[:pending_listing_id].present?
        listing = Listing.find_by(id: session[:pending_listing_id])
        if listing && listing.user.nil?
          listing.update(user: user, status: :active)
          session.delete(:pending_listing_id)
        end
      end
    end
  end
end 