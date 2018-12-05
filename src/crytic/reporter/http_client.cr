require "http/client"
require "json"

module Crytic::Reporter
  abstract class HttpClient
    abstract def post(url : String, body : Hash(String, String | Float64))
  end

  class DefaultHttpClient < HttpClient
    def post(url : String, body : Hash(String, String | Float64))
      HTTP::Client.post(url, headers: HTTP::Headers{"Content-Type" => "application/json"}, body: body.to_json)
    end
  end
end
