class Api::V1::UsersController < Api::V1::BaseController

  require 'json'
  require 'net/http'
  require 'uri'

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def show
    render(json: {:method=>"show"}.to_json, status: 201)
  end

  def index
    puts SnatchController.example
    # SnatchController.snatch
    render(json: {:method=>"index", :note=>"#{SnatchController.example}"}.to_json, status: 201)
  end

  def custom
    render(json: {:method=>"custom"}.to_json, status: 201)
  end

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end

end