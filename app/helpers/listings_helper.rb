module ListingsHelper
  def fuel_type_icon(fuel_type)
    case fuel_type.to_s.downcase
    when "essence"
      "bi-fuel-pump"
    when "diesel"
      "bi-fuel-pump-diesel"
    when "hybride"
      "bi-ev-station"
    when "électrique"
      "bi-lightning-charge"
    when "gpl"
      "bi-droplet"
    else
      "bi-fuel-pump"
    end
  end
  
  def transmission_icon(transmission)
    case transmission.to_s.downcase
    when "manuelle"
      "bi-gear-wide"
    when "automatique"
      "bi-gear-wide-connected"
    when "semi-automatique"
      "bi-sliders"
    else
      "bi-gear-wide"
    end
  end
  
  def equipment_icon(equipment)
    equipment = equipment.to_s.downcase
    
    if equipment.include?("climatisation") || equipment.include?("clim")
      "bi-thermometer-snow"
    elsif equipment.include?("bluetooth") || equipment.include?("connect")
      "bi-bluetooth"
    elsif equipment.include?("toit") || equipment.include?("panoramique")
      "bi-stars"
    elsif equipment.include?("caméra") || equipment.include?("radar")
      "bi-camera"
    elsif equipment.include?("siège") || equipment.include?("seat")
      "bi-chair"
    elsif equipment.include?("jante") || equipment.include?("alliage")
      "bi-circle"
    elsif equipment.include?("airbag") || equipment.include?("sécurité")
      "bi-shield-check"
    elsif equipment.include?("gps") || equipment.include?("navigation")
      "bi-geo-alt"
    elsif equipment.include?("volant") || equipment.include?("cuir")
      "bi-circle-half"
    elsif equipment.include?("audio") || equipment.include?("sound") || equipment.include?("hifi")
      "bi-music-note-beamed"
    elsif equipment.include?("park") || equipment.include?("stationnement")
      "bi-p-circle"
    else
      "bi-check-circle"
    end
  end
  
  def recently_created?(listing)
    listing.created_at >= 7.days.ago
  end
  
  def search_summary(params)
    filters = []
    
    filters << "Catégorie: #{Category.find(params[:category_id]).name}" if params[:category_id].present?
    filters << "Type: #{params[:subcategory]}" if params[:subcategory].present?
    filters << "Marque: #{params[:make]}" if params[:make].present?
    filters << "Modèle: #{params[:model]}" if params[:model].present?
    
    if params[:price_min].present? || params[:price_max].present?
      price_range = "Prix: "
      price_range += "min #{params[:price_min]}€" if params[:price_min].present?
      price_range += " - " if params[:price_min].present? && params[:price_max].present?
      price_range += "max #{params[:price_max]}€" if params[:price_max].present?
      filters << price_range
    end
    
    filters << "Carburant: #{params[:fuel_type].join(', ')}" if params[:fuel_type].is_a?(Array) && params[:fuel_type].any?
    filters << "Transmission: #{params[:transmission].join(', ')}" if params[:transmission].is_a?(Array) && params[:transmission].any?
    
    filters.empty? ? "Tous les véhicules" : filters.join(' • ')
  end
  
  def sort_label(sort_param)
    case sort_param
    when "date_desc"
      "Plus récentes"
    when "date_asc"
      "Plus anciennes"
    when "price_asc"
      "Prix croissant"
    when "price_desc"
      "Prix décroissant"
    when "km_asc"
      "Kilométrage croissant"
    when "year_desc"
      "Année: plus récentes"
    when "year_asc"
      "Année: plus anciennes"
    else
      nil
    end
  end
  
  def listing_status_color(status)
    case status.to_s
    when "active"
      "bg-green-100 text-green-800"
    when "draft"
      "bg-yellow-100 text-yellow-800"
    when "sold"
      "bg-blue-100 text-blue-800"
    when "archived"
      "bg-gray-100 text-gray-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
