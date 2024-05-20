# ameba:disable Lint/SpecFilename
require "../src/crytic/reporter/http_client"
require "http/server/response"

class FakeHttpClient < Crytic::Reporter::HttpClient
  alias ResponseBody = Hash(String, String | Float64)
  getter path : String?, body : ResponseBody?
  property response = HTTP::Server::Response.new(IO::Memory.new)

  def post(url : String, body : ResponseBody)
    @path = url
    @body = body
    response
  end
end
