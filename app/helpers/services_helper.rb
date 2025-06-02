module ServicesHelper
  def category_icon(category_name)
    icons = {
      'Mécanique' => '🔧',
      'Carrosserie' => '🚗',
      'Électricité' => '⚡',
      'Pneumatiques' => '🛞',
      'Transport' => '🚛',
      'Nettoyage' => '🧽',
      'Vitrage' => '🪟',
      'Climatisation' => '❄️',
      'Diagnostic' => '🔍',
      'Tuning' => '⚙️'
    }
    icons[category_name] || '🔧'
  end

  def badge_color(badge_type)
    colors = {
      'verified' => 'success',
      'premium' => 'warning',
      'top_rated' => 'info',
      'quick_response' => 'accent',
      'experienced' => 'secondary'
    }
    colors[badge_type] || 'neutral'
  end

  def badge_text(badge_type)
    texts = {
      'verified' => 'Vérifié',
      'premium' => 'Premium',
      'top_rated' => 'Top Rated',
      'quick_response' => 'Réponse Rapide',
      'experienced' => 'Expérimenté'
    }
    texts[badge_type] || badge_type.humanize
  end

  def service_status_badge(status)
    colors = {
      'pending' => 'warning',
      'active' => 'success',
      'suspended' => 'error',
      'rejected' => 'error'
    }
    
    content_tag :div, class: "badge badge-#{colors[status]} badge-sm" do
      status.humanize
    end
  end

  def booking_status_badge(status)
    colors = {
      'pending' => 'warning',
      'accepted' => 'info',
      'in_progress' => 'primary',
      'completed' => 'success',
      'cancelled' => 'error',
      'disputed' => 'error'
    }
    
    content_tag :div, class: "badge badge-#{colors[status]} badge-sm" do
      status.humanize
    end
  end

  def rating_stars(rating, size: 'sm')
    content_tag :div, class: "rating rating-#{size}" do
      5.times.map do |i|
        content_tag :input, '', 
          type: 'radio', 
          class: "mask mask-star-2 bg-orange-400",
          disabled: true,
          checked: i < rating.round
      end.join.html_safe
    end
  end

  def format_price_range(min_price, max_price)
    if min_price && max_price
      "#{min_price}€ - #{max_price}€"
    elsif min_price
      "À partir de #{min_price}€"
    elsif max_price
      "Jusqu'à #{max_price}€"
    else
      "Prix sur devis"
    end
  end

  def urgency_badge(urgency)
    colors = {
      'low' => 'success',
      'medium' => 'warning',
      'high' => 'error',
      'urgent' => 'error'
    }
    
    texts = {
      'low' => 'Faible',
      'medium' => 'Moyenne',
      'high' => 'Élevée',
      'urgent' => 'Urgente'
    }
    
    content_tag :div, class: "badge badge-#{colors[urgency]} badge-sm" do
      texts[urgency]
    end
  end

  def distance_text(distance_km)
    if distance_km < 1
      "#{(distance_km * 1000).round}m"
    else
      "#{distance_km.round(1)}km"
    end
  end

  def service_provider_avatar(provider, size: 'w-12 h-12')
    if provider.profile_image.attached?
      image_tag provider.profile_image, 
        class: "#{size} rounded-full object-cover"
    else
      content_tag :div, class: "avatar placeholder" do
        content_tag :div, class: "bg-neutral text-neutral-content rounded-full #{size}" do
          content_tag :span, provider.business_name.first.upcase
        end
      end
    end
  end

  def format_response_time(hours)
    if hours < 1
      "< 1h"
    elsif hours < 24
      "#{hours.round}h"
    else
      "#{(hours / 24).round}j"
    end
  end

  def service_request_deadline_status(deadline)
    days_left = (deadline - Date.current).to_i
    
    if days_left < 0
      { text: "Expiré", class: "badge-error" }
    elsif days_left == 0
      { text: "Aujourd'hui", class: "badge-warning" }
    elsif days_left == 1
      { text: "Demain", class: "badge-warning" }
    elsif days_left <= 7
      { text: "#{days_left} jours", class: "badge-info" }
    else
      { text: "#{days_left} jours", class: "badge-neutral" }
    end
  end
end 