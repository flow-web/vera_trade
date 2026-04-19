module ApplicationHelper
  include Pagy::Frontend

  def photo_url(attachment)
    return nil unless attachment&.attached?
    blob = attachment.is_a?(ActiveStorage::Attached) ? attachment.blob : attachment
    blob.url
  rescue
    url_for(attachment)
  end
end
