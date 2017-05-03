class SnatchController < ApplicationController
  require 'json'
  require 'net/http'

  def link
    if request.env['omniauth.auth']
      if current_user
        current_user.access_token = request.env['omniauth.auth'][:credentials][:token]
        current_user.refresh_token = request.env['omniauth.auth'][:credentials][:refresh_token]
        p_set = JSON.parse(current_user.settings)
        p_set["user_id"] = get('me')["id"]
        current_user.settings = p_set.to_json
        current_user.save!
      else
        response = request.env['omniauth.auth']
        session[:token] = response[:credentials][:token]
      end
    end
    redirect_to root_path
  end

  def about
    if current_user && !current_user.access_token 
      redirect_to "/auth/spotify"
    end
    if session[:que] == true
      session[:que] = false
      guest_snatch
    end
  end

  def options
  end

  def fail
    flash[:alert] = "Rejected"
    redirect_to root_path
  end

  def update
    if params[:session][:p_name] != ''
      p_set = JSON.parse(current_user.settings)
      p_set["p_name"] = params[:session][:p_name]
      current_user.settings = p_set.to_json
      current_user.save!
      session[:p_name] = JSON.parse(current_user.settings)["p_name"]
      flash[:notice] =  "Playlist name update to #{session[:p_name]}"
    end
    redirect_to root_path
  end

  def snatch
    begin
      session[:user_id] = get('me')['id']
      get_song
      check_for_playlist
      actually_snatch
    rescue
      puts "Rescued"
    end
    redirect_to root_path
  end

  def guest_snatch
    if session[:token]
      session[:user_id] = get('me')['id']
      get_song
      check_for_playlist
      actually_snatch
      redirect_to root_path
    else
      session[:que] = true
      redirect_to "/auth/spotify"
    end
  end

  def get_song
    begin
      song = get('me/player/currently-playing')
      session[:s_uri] = song['item']['uri']
      session[:s_name] = song['item']['name']
      puts "get_song complete, got #{session[:s_name]}"
    rescue
      flash[:alert] = "Could not get current song. Are you sure one is playing?"
    end
  end

  def check_for_playlist
    if current_user
      session[:p_name] = JSON.parse(current_user.settings)["p_name"]
    else
      session[:p_name] = "Snatched"
    end
    get('me/playlists?limit=50')['items'].each do |x|
        if x['name'] === session[:p_name]
          puts x['name'] << ' Playlist found'
          session[:p_id] = x['id']
          return
        end
      end
      puts "check_for_playlist complete, playlist not found, creating"
      create_playlist
  end

  def create_playlist
    playlist = post("users/#{session[:user_id]}/playlists", {
      "description" => "Your Snatched Playlist",
      "public" => false,
      "name" => "#{session[:p_name]}"
    })
    session[:p_id] = playlist['id']
    puts "create_playlist complete #{current_user[:p_name]} playlist created. ID: #{session[:p_id]}"
  end

  def actually_snatch
    playlist = get("users/#{session[:user_id]}/playlists/#{session[:p_id]}/tracks")
    for i in 0..(playlist['items'].length - 1)
      if playlist['items'][i]['track']['uri'] === session[:s_uri]
        puts "That song has already been snatched"
        flash[:alert] = "Silly goat, #{session[:s_name]} has already been snatched"
        return
      end
    end
    post("users/#{session[:user_id]}/playlists/#{session[:p_id]}/tracks?uris=#{session[:s_uri]}")
    flash[:notice] = "#{session[:s_name]} was sucsessfully added to #{session[:p_name]}"
  end

  def get(endpoint)
    uri = URI.parse("https://api.spotify.com/v1/#{endpoint}")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    if current_user
      request["Authorization"] = "Bearer #{current_user.access_token}"
    else
      request["Authorization"] = "Bearer #{session[:token]}"
    end
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
    if current_user
      request["Authorization"] = "Bearer #{current_user.access_token}"
    else
      request["Authorization"] = "Bearer #{session[:token]}"
    end
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