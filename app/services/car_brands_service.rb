class CarBrandsService
  # Liste des marques de voitures les plus courantes en France
  BRANDS = [
    "Abarth", "Alfa Romeo", "Aston Martin", "Audi", "BMW", "Chevrolet", "Chrysler", "Citroën",
    "Dacia", "Dodge", "Ferrari", "Fiat", "Ford", "Honda", "Hyundai", "Infiniti", "Jaguar",
    "Jeep", "Kia", "Lamborghini", "Land Rover", "Lexus", "Lotus", "Maserati", "Mazda",
    "McLaren", "Mercedes-Benz", "Mini", "Mitsubishi", "Nissan", "Opel", "Peugeot", "Porsche",
    "Renault", "Rolls-Royce", "Seat", "Skoda", "Smart", "SsangYong", "Subaru", "Suzuki",
    "Tesla", "Toyota", "Volkswagen", "Volvo"
  ].freeze

  def self.search(query)
    return [] if query.blank?
    
    query = query.downcase
    BRANDS.select { |brand| brand.downcase.include?(query) }
  end

  def self.all
    BRANDS
  end
end 