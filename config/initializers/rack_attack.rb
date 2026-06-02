class Rack::Attack
  throttle("extension api/ip", limit: 120, period: 1.minute) do |request|
    request.ip if request.path.start_with?("/api/v1")
  end

  throttle("admin login/ip", limit: 10, period: 5.minutes) do |request|
    request.ip if request.path == "/admin/login" && request.post?
  end

  self.throttled_responder = lambda do |_request|
    [429, { "Content-Type" => "application/json" }, [{ error: "Rate limit exceeded. Please try again later." }.to_json]]
  end
end
