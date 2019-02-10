require "../src/crytic/reporter/http_client"

class FakeHttpClient < Crytic::Reporter::HttpClient
  def post(url : String, bbody : Hash(String, String | Float64))
    @path = url
    @body = bbody
  end

  def path
    @path
  end

  def body
    @body
  end
end
