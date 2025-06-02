class AddServiceCategoriesToCategories < ActiveRecord::Migration[8.0]
  def up
    # Ajouter des catégories de services si elles n'existent pas
    service_categories = [
      'Mécanique',
      'Carrosserie', 
      'Électricité',
      'Pneumatiques',
      'Transport',
      'Nettoyage',
      'Vitrage',
      'Climatisation',
      'Diagnostic',
      'Tuning'
    ]

    service_categories.each do |category_name|
      Category.find_or_create_by(name: category_name)
    end
  end

  def down
    # Ne pas supprimer les catégories car elles peuvent être utilisées ailleurs
  end
end
