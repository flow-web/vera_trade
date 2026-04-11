module ApplicationHelper
  # Pagy frontend helpers (pagy_nav, pagy_info, pagy_prev_link, pagy_next_link)
  # are used in app/views/listings/index.html.erb for catalogue pagination.
  include Pagy::Frontend
end
