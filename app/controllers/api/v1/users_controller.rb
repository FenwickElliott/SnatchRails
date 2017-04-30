class Api::V1::UsersController < Api::V1::BaseController
  require 'json'
  require 'net/http'

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def snatch
    get_user_info
    get_song
    check_for_playlist
    post("users/#{@user_id}/playlists/#{@p_id}/tracks?uris=#{@s_uri}")
  end

  def get_user_info
    @user_id = get('me')['id']
    @ans << "Got @user_id: #{@user_id}\n"

    # two line implemental runs faster than one line implimentation. Why?
    settings = JSON.parse User.find(params[:id]).settings
    @p_name = settings['p_name']
    # p_name = JSON.parse(User.find(params[:id]).settings)['p_name']
    @ans << "Got p_name: #{@p_name}\n"
  end

  def get_song
    @s_uri = get('me/player/currently-playing')['item']['uri']
    @s_name = get('me/player/currently-playing')['item']['name']
    @ans << "Got song: #{@s_name}\n"
  end

  def check_for_playlist
    list = get('me/playlists?limit=50')
    list['items'].each do |x|
    # get('me/playlists?limit=50')'items'].each do |x|
      if x['name'] === @p_name
        @p_id = x['id']
        @ans << "Playlist found, p_id: #{@p_id}\n"
        return
      end
    end
    @ans << "check_for_playlist complete, playlist not found. Creating...\n"
    create_playlist
  end

  def create_playlist
    playlist = post("users/#{@user_id}/playlists", {
      "description" => "Your Snatched Playlist",
      "public" => false,
      "name" => @p_name
    })
    @p_id = playlist['id']
    @ans << "create_playlist complete #{@p_name} playlist created. ID: #{@p_id}\n"
  end

  def show
    @ans = ""
    @user = User.find(params[:id])
    @access_token = User.find(params[:id]).access_token
    begin
      @ans << "Got token\n"
      snatch
      render json: @ans
    rescue
      @ans << "Token Refreshed"
      cycle_tokens
      snatch
      render json: @ans
    end
  end

  def index
  end

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end

  def cycle_tokens
    puts "cycling tokens..."
    uri = URI.parse("https://accounts.spotify.com/api/token")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Basic ZWJkNTM1NDVlZTA0NGI3OGE2MTc5OTk4ZjBkZGZiNDA6MjIzMjY3ZmNmMjI0NGJhYWI1OTIwMDVjMzI4Y2E2Y2U="
    request.set_form_data(
      "grant_type" => "refresh_token",
      "refresh_token" => User.find(params[:id]).refresh_token
    )
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    @access_token = JSON.parse(response.body)['access_token']
    @user.access_token = @access_token
    @user.save!
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
    request["Authorization"] = "Bearer #{@access_token}"
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