class ListingQuestion < ApplicationRecord
  belongs_to :listing
  belongs_to :user
  has_one :answer, class_name: "ListingAnswer", dependent: :destroy

  validates :body, presence: true

  scope :published, -> { where(published: true) }
end
