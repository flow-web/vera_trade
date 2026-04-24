Rack::Attack.throttle("logins/ip", limit: 5, period: 60.seconds) do |req|
  req.ip if req.path == "/users/sign_in" && req.post?
end

Rack::Attack.throttle("signups/ip", limit: 3, period: 60.seconds) do |req|
  req.ip if req.path == "/users" && req.post?
end

Rack::Attack.throttle("password_resets/ip", limit: 3, period: 60.seconds) do |req|
  req.ip if req.path == "/users/password" && req.post?
end

Rack::Attack.throttle("contact/ip", limit: 10, period: 5.minutes) do |req|
  req.ip if req.path.match?(%r{/listings/.+/listing_contacts}) && req.post?
end

Rack::Attack.throttle("questions/ip", limit: 5, period: 5.minutes) do |req|
  req.ip if req.path.match?(%r{/listings/.+/listing_questions}) && req.post?
end

Rack::Attack.throttle("messages/ip", limit: 20, period: 5.minutes) do |req|
  req.ip if req.path.match?(%r{/conversations/.+/messages}) && req.post?
end

Rack::Attack.throttle("vehicle_fetch/ip", limit: 10, period: 1.minute) do |req|
  req.ip if req.path == "/vehicles/fetch_info"
end

Rack::Attack.throttle("bids/ip", limit: 10, period: 1.minute) do |req|
  req.ip if req.path.match?(%r{/auctions/\d+/place_bid}) && req.post?
end

Rack::Attack.throttle("bids/user", limit: 5, period: 30.seconds) do |req|
  if req.path.match?(%r{/auctions/\d+/place_bid}) && req.post?
    req.env["warden"]&.user&.id
  end
end

Rack::Attack.throttled_responder = lambda do |_request|
  [ 429, { "Content-Type" => "application/json" }, [{ error: "Trop de requêtes, réessayez dans quelques instants" }.to_json] ]
end
