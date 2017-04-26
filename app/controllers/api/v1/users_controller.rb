class Api::V1::UsersController < Api::V1::BaseController

  require 'json'
  require 'net/http'

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def show
    user = User.find(params[:id])
    user.access_token = "Hi"
    puts user.access_token

    unless snatch
      cycle_tokens
      snatch
    end
    
    # render json: user, status: 200
  end

  def index
  end

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end

  def cycle_tokens
    # uri = URI.parse("https://accounts.spotify.com/api/token")
    # request = Net::HTTP::Post.new(uri)
    # request.content_type = "application/json"
    # request["Accept"] = "application/json"
    # request["Authorization"] = "Bearer #{session[:token]}"
    # request.body = JSON.dump body
    # req_options = {
    #   use_ssl: uri.scheme == "https",
    # }
    # response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    #   http.request(request)
    # end
    # JSON.parse response.body
  end

  def snatch

  end


  def get(endpoint)
    uri = URI.parse("https://api.spotify.com/v1/#{endpoint}")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer BQDFX19JzO7m5MH4DaZItywR3WCeXlq08oSdxNHgoDY3XPJAFRolrlW1LcIN3YxL4GeO1vWCpxloyR33F7hCCcW79VwqLyjx2NVsP47rThCv_WUByYysA5jSXowJVPcRkOGXpyZavFbpmMXTWS6NjhKpVOkqw8tHQKYV5kgnwpMfIHL5FJFfZBfyqdeNS_oNErnSiOqpw36LWV65wKCNSCAH4FoYyxEsaAZnX-PhjsNvAo8b_O15wNbPPnp_ZZPYZOOluVDLXctWbNmA87ZOoget1EIyWFpdib5gbiJ9zr5PQH694kjWBNL1C-RTtmc}"
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    JSON.parse response.body
  end

  def post(endpoint, body = {})
    uri = URI.parse("https://api.spotify.com/v1/#{endpoint}")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{session[:token]}"
    request.body = JSON.dump body
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    JSON.parse response.body
  end
end