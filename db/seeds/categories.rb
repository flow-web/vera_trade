# Script pour créer les catégories de véhicules
puts "Création des catégories de véhicules..."

# Supprimer les catégories existantes
Category.destroy_all

# Créer les catégories principales à partir des types de véhicules dans le modèle Vehicle
Vehicle.vehicle_types.keys.each do |category_name|
  category = Category.create!(
    name: category_name.to_s,
    slug: category_name.to_s.parameterize,
    description: "Tous les véhicules de type #{category_name}",
    icon: "bi-#{category_name.to_s.parameterize}"
  )
  
  puts "Catégorie créée: #{category.name}"
  
  # Créer les sous-catégories pour chaque catégorie principale
  Vehicle.vehicle_types[category_name].each do |subcategory_name|
    next if subcategory_name == "Autre" # Ne pas créer de sous-catégorie "Autre"
    
    subcategory = Category.create!(
      name: subcategory_name,
      slug: subcategory_name.parameterize,
      description: "#{subcategory_name} - #{category.name}",
      parent: category,
      icon: "bi-#{subcategory_name.parameterize}"
    )
    
    puts "  Sous-catégorie créée: #{subcategory.name}"
  end
end

puts "Création des catégories terminée ! #{Category.count} catégories créées." 