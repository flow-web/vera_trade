module ApplicationHelper
  include Pagy::Frontend

  def photo_url(attachment)
    return nil if attachment.nil?
    blob = case attachment
           when ActiveStorage::Blob then attachment
           when ActiveStorage::Attachment then attachment.blob
           else attachment.respond_to?(:blob) ? attachment.blob : nil
           end
    return rails_blob_path(blob, only_path: true) unless blob&.service_name&.to_s == "cloudinary"
    blob.url
  end
end
