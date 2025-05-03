# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Ce fichier contient les données initiales nécessaires à l'application
# db/seeds.rb

# Charger les seeds pour les catégories
require_relative 'seeds/categories'

puts "Toutes les seeds ont été chargées avec succès !"
