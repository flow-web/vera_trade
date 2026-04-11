class ListingAnswer < ApplicationRecord
  belongs_to :listing_question
  belongs_to :user

  validates :body, presence: true
end
