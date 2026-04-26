require "open-uri"
require "tempfile"

PHOTO_SOURCES = {
  "Porsche 911" => [
    "https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?w=1200",
    "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=1200",
    "https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=1200",
    "https://images.unsplash.com/photo-1580274455191-1c62238fa333?w=1200",
  ],
  "Mercedes G63" => [
    "https://images.unsplash.com/photo-1520031441872-265e4ff70366?w=1200",
    "https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=1200",
    "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=1200",
  ],
  "BMW M3" => [
    "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=1200",
    "https://images.unsplash.com/photo-1555215695-3004980ad54e?w=1200",
    "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=1200",
    "https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=1200",
  ],
  "Audi RS6" => [
    "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=1200",
    "https://images.unsplash.com/photo-1603386329225-868f9b1ee6c9?w=1200",
    "https://images.unsplash.com/photo-1542362567-b07e54358753?w=1200",
  ],
  "Alpine A110" => [
    "https://images.unsplash.com/photo-1619405399517-d7fce0f13302?w=1200",
    "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=1200",
    "https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=1200",
  ],
  "Tesla Model 3" => [
    "https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=1200",
    "https://images.unsplash.com/photo-1571987502227-9231b837d92a?w=1200",
    "https://images.unsplash.com/photo-1562911791-c7a97b729ec5?w=1200",
  ],
  "Peugeot 208" => [
    "https://images.unsplash.com/photo-1549317661-bd32c8ce0afa?w=1200",
    "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=1200",
    "https://images.unsplash.com/photo-1502877338535-766e1452684a?w=1200",
  ],
  "Ducati" => [
    "https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=1200",
    "https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=1200",
    "https://images.unsplash.com/photo-1547549082-6bc09f2049ae?w=1200",
  ],
  "Triumph" => [
    "https://images.unsplash.com/photo-1558980664-769d59546b3d?w=1200",
    "https://images.unsplash.com/photo-1609630875171-b1321377ee65?w=1200",
    "https://images.unsplash.com/photo-1571646750149-3e7c1fd56f42?w=1200",
  ],
  "VW Golf" => [
    "https://images.unsplash.com/photo-1617469955236-7f11e7942257?w=1200",
    "https://images.unsplash.com/photo-1471444928039-1e6748244da0?w=1200",
    "https://images.unsplash.com/photo-1590362891991-f776e747a588?w=1200",
  ],
}

LISTING_MAP = {
  6 => "Porsche 911",
  7 => "Mercedes G63",
  8 => "BMW M3",
  9 => "Audi RS6",
  10 => "Alpine A110",
  12 => "Tesla Model 3",
  11 => "Peugeot 208",
  14 => "Ducati",
  15 => "Triumph",
  13 => "VW Golf",
}

LISTING_MAP.each do |listing_id, search_key|
  listing = Listing.find_by(id: listing_id)
  next unless listing
  next if listing.photos.attached? && listing.photos.count >= 3

  urls = PHOTO_SOURCES[search_key]
  next unless urls

  puts "Attaching #{urls.size} photos to listing ##{listing_id} (#{listing.title})..."

  urls.each_with_index do |url, i|
    begin
      tempfile = Tempfile.new(["photo_#{listing_id}_#{i}", ".jpg"])
      tempfile.binmode
      URI.open(url) { |remote| IO.copy_stream(remote, tempfile) }
      tempfile.rewind

      listing.photos.attach(
        io: tempfile,
        filename: "#{search_key.parameterize}-#{i + 1}.jpg",
        content_type: "image/jpeg"
      )
      puts "  ✓ Photo #{i + 1}/#{urls.size}"
      tempfile.close!
    rescue => e
      puts "  ✗ Photo #{i + 1} failed: #{e.message}"
    end
  end
end

puts "\nDone! Photos count per listing:"
Listing.where(status: "active").each do |l|
  puts "  #{l.id} | #{l.title} | #{l.photos.count} photos"
end
