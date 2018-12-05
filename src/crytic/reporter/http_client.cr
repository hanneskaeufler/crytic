module Crytic::Reporter
  abstract class HttpClient
    abstract def post(url, body : Hash(String, String | Float64))
  end
end
