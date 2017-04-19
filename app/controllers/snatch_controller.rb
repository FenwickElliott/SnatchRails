class SnatchController < ApplicationController
  require 'json'
  require 'net/http'
  require 'uri'

  def about
    if request.env['omniauth.auth']
      session[:response] = request.env['omniauth.auth']
      session[:token] = session[:response][:credentials][:token]
      session[:header] = {
        Accept: "application/json",
        Authorization: "Authorization: Bearer #{session[:token]}"
      }
      get_me
      if current_user
        session[:p_name] = JSON.parse(current_user.settings)["p_name"]
      else
        session[:p_name] = "Snatched"
      end
    end
  end

  def options
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


  def link
    redirect_to "/auth/spotify"
  end

  def guest_snatch
    unless session[:user_id]
      redirect_to "/auth/spotify"
    end
      begin
      get_song
      check_for_playlist
      check_through_playlist
      # actually_snatch
      redirect_to root_path
    rescue
    end
  end

  def snatch
    unless session[:user_id]
      redirect_to "/auth/spotify"
    end
    
    begin
      get_song
      check_for_playlist
      check_through_playlist
      # actually_snatch
      redirect_to root_path
    rescue
    end
  end

  def get_me
    begin
      user = get('me')
      session[:user_id] = user['id']
      puts "got me: #{session[:user_id]}"
    rescue
      puts "couldn't access spotify api"
      flash[:alert] = "I'm sorry, we couldn't access the Spotify API, which is problematic..."
    end
  end

  def get_song
    song = get('me/player/currently-playing')
    session[:s_uri] = song['item']['uri']
    session[:s_name] = song['item']['name']
    puts "get_song complete, got #{session[:s_name]}"
  end

  def check_for_playlist
    if true
      list = get('me/playlists?limit=50')
      list['items'].each do |x|
          if x['name'] === session[:p_name]

            puts x['name'] << ' Playlist found'
            session[:p_id] = x['id']
            return
          end
        end
        puts "check_for_playlist complete, playlist not found, creating"
        create_playlist
      end
      puts "check_for_playlist complete, playlist found"
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
    post("users/#{session[:user_id]}/playlists/#{session[:p_id]}/tracks?uris=#{session[:s_uri]}")
    flash[:notice] = "#{session[:s_name]} was sucsessfully added to #{session[:p_name]}"
  end

  def check_through_playlist
    playlist = get("users/#{session[:user_id]}/playlists/#{session[:p_id]}/tracks")
    for i in 0..(playlist['items'].length - 1)
      if playlist['items'][i]['track']['uri'] === session[:s_uri]
        puts "That song has already been snatched"
        flash[:alert] = "Silly goat, #{session[:s_name]} has already been snatched"
        redirect_to root_path
        return
      end
    end
    puts "check_through_playlist complete"
    actually_snatch
  end

  def get(endpoint)
    uri = URI.parse("https://api.spotify.com/v1/#{endpoint}")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{session[:token]}"
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
