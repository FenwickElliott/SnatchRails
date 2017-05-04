class Api::V1::ActionsController < Api::V1::BaseController
  require 'json'
  require 'net/http'
  require 'base64'

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  before_action :authenticate

  def snatch
    @ans = "snatching...\n"
    @access_token = @user.access_token
    begin
      @ans << "Got token: #{@access_token}\n"
      actually_snatch
      render json: @ans
    rescue
      cycle_tokens
      @ans << "Token Refreshed: #{@access_token}\n"
      actually_snatch
      render json: @ans
    end
  end

  def actually_snatch
    get_user_info
    get_song
    check_for_playlist
    if check_through_playlist
      @ans << "That has already been snatched\n"
    else
      post("users/#{@user_id}/playlists/#{@p_id}/tracks?uris=#{@s_uri}")
      @ans << "Snatched!!!\n"
    end
  end

  def get_user_info
    @user_id = get('me')['id']
    @ans << "Got @user_id: #{@user_id}\n"
    @p_name = JSON.parse(@user.settings)['p_name']
    @ans << "Got p_name: #{@p_name}\n"
  end

  def get_song
    @s_uri = get('me/player/currently-playing')['item']['uri']
    @s_name = get('me/player/currently-playing')['item']['name']
    @ans << "Got song: #{@s_name}\n"
  end

  def check_for_playlist
    get('me/playlists?limit=50')['items'].each do |x|
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

  def check_through_playlist
    playlist = get("users/#{@user_id}/playlists/#{@p_id}/tracks")
    for i in 0..(playlist['items'].length - 1)
      if playlist['items'][i]['track']['uri'] === @s_uri
        return true
      end
    end
    return false
  end

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end

  def cycle_tokens
    puts "cycling tokens..."
    uri = URI.parse("https://accounts.spotify.com/api/token")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Basic " << Base64.strict_encode64("#{ENV['SPOTIFY_CLIENT_ID']}:#{ENV['SPOTIFY_CLIENT_SECRET']}").to_s
    request.set_form_data(
      "grant_type" => "refresh_token",
      "refresh_token" => @user.refresh_token
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

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end

  protected
  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @user = User.find_by(auth_token: token)
    end
  end
end