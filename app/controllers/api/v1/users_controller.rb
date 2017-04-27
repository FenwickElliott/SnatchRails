class Api::V1::UsersController < Api::V1::BaseController
  require 'json'
  require 'net/http'

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def show
    @ans = ""
    @access_token = User.find(params[:id]).access_token
    @refresh_token = User.find(params[:id]).refresh_token
    @ans << "Got token\n"

    puts get('me')['id']

    begin
      user_id = get('me')['id']
      @ans << "Got user_id: #{user_id}\n"

      s_uri = get('me/player/currently-playing')['item']['uri']
      s_name = get('me/player/currently-playing')['item']['name']
      @ans << "Got song: #{s_name}\n"


      # two line implemental runs faster than one line implimentation. Why?
      settings = JSON.parse User.find(params[:id]).settings
      @p_name = settings['p_name']
      # p_name = JSON.parse(User.find(params[:id]).settings)['p_name']
      @ans << "Got p_name: #{@p_name}\n"

      check_for_playlist
      render json: @ans, status: 200
    rescue
      cycle_tokens
    end
  end

  def index
  end

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end

  def cycle_tokens
    uri = URI.parse("https://accounts.spotify.com/api/token")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Basic ZWJkNTM1NDVlZTA0NGI3OGE2MTc5OTk4ZjBkZGZiNDA6MjIzMjY3ZmNmMjI0NGJhYWI1OTIwMDVjMzI4Y2E2Y2U="
    request.set_form_data(
      "grant_type" => "refresh_token",
      "refresh_token" => @refresh_token,
    )
    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    @access_token = JSON.parse(response.body)['access_token']
    

    render json: response.code
  end

  def check_for_playlist
      list = get('me/playlists?limit=50')
      list['items'].each do |x|
        if x['name'] === @p_name
          p_id = x['id']
          @ans << "Playlist found, p_id: #{p_id}\n"
          return
        end
      end
      @ans << "check_for_playlist complete, playlist not found. Creating...\n"
      # create_playlist
  end


  def get(endpoint)
    uri = URI.parse("https://api.spotify.com/v1/#{endpoint}")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{@access_token}"
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