class AddSampleCoordinatesToExistingVehicles < ActiveRecord::Migration[8.0]
  def up
    # Ajouter des coordonnées de test pour les véhicules existants
    # Coordonnées de différentes villes françaises
    sample_locations = [
      { lat: 48.8566, lng: 2.3522, address: "Paris, France" },
      { lat: 45.7640, lng: 4.8357, address: "Lyon, France" },
      { lat: 43.2965, lng: 5.3698, address: "Marseille, France" },
      { lat: 47.2184, lng: -1.5536, address: "Nantes, France" },
      { lat: 50.6292, lng: 3.0573, address: "Lille, France" },
      { lat: 44.8378, lng: -0.5792, address: "Bordeaux, France" },
      { lat: 43.6047, lng: 1.4442, address: "Toulouse, France" },
      { lat: 49.2628, lng: 4.0347, address: "Reims, France" },
      { lat: 47.4784, lng: -0.5632, address: "Angers, France" },
      { lat: 45.1885, lng: 5.7245, address: "Grenoble, France" }
    ]
    
    # Mettre à jour les véhicules existants avec des coordonnées aléatoires
    Vehicle.where(latitude: nil, longitude: nil).find_each.with_index do |vehicle, index|
      location = sample_locations[index % sample_locations.length]
      
      # Ajouter une petite variation aléatoire pour éviter d'avoir tous les véhicules au même endroit
      lat_variation = (rand - 0.5) * 0.1  # ±0.05 degrés (environ ±5.5 km)
      lng_variation = (rand - 0.5) * 0.1
      
      vehicle.update_columns(
        latitude: location[:lat] + lat_variation,
        longitude: location[:lng] + lng_variation,
        address: location[:address]
      )
    end
    
    puts "Coordonnées ajoutées à #{Vehicle.with_coordinates.count} véhicules"
  end
  
  def down
    # Optionnel: supprimer les coordonnées de test si nécessaire
    Vehicle.update_all(latitude: nil, longitude: nil, address: nil)
  end
end
