class Category < ApplicationRecord
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "Category", optional: true
  
  has_many :vehicles
  
  validates :name, presence: true, uniqueness: { scope: :parent_id }
  
  scope :main_categories, -> { where(parent_id: nil) }
  scope :subcategories, -> { where.not(parent_id: nil) }
  
  def main_category?
    parent_id.nil?
  end
  
  def subcategory?
    parent_id.present?
  end
end
