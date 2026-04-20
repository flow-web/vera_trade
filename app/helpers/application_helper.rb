module ApplicationHelper
  include Pagy::Frontend

  # Returns an optimized image URL.
  # For Cloudinary-hosted blobs, appends f_auto,q_auto and optional width transform.
  # Usage:
  #   photo_url(attachment)                # original (no resize)
  #   photo_url(attachment, width: 1600)   # hero images
  #   photo_url(attachment, width: 400)    # thumbnails
  def photo_url(attachment, width: nil)
    return nil if attachment.nil?
    blob = case attachment
           when ActiveStorage::Blob then attachment
           when ActiveStorage::Attachment then attachment.blob
           else attachment.respond_to?(:blob) ? attachment.blob : nil
           end
    return rails_blob_path(blob, only_path: true) unless blob&.service_name&.to_s == "cloudinary"

    raw_url = blob.url
    cloudinary_transform(raw_url, width: width)
  end

  private

  # Inserts Cloudinary on-the-fly transforms into an existing URL.
  # Transforms: f_auto (AVIF/WebP negotiation), q_auto (quality), w_N (resize).
  # Example input:  https://res.cloudinary.com/xxx/image/upload/v123/file.jpg
  # Example output: https://res.cloudinary.com/xxx/image/upload/f_auto,q_auto,w_1600/v123/file.jpg
  def cloudinary_transform(url, width: nil)
    return url if url.blank?

    transforms = ["f_auto", "q_auto"]
    transforms << "w_#{width}" if width

    transform_str = transforms.join(",")

    # Insert transforms after /upload/ (standard Cloudinary URL structure)
    url.sub(%r{/upload/}, "/upload/#{transform_str}/")
  end
end
