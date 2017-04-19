class Api::V1::UsersController < Api::V1::BaseController

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def show
    render(json: {:name=>"Charles"}.to_json)
  end

  def index
    render(json: {:name=>"Charlie"}.to_json)
  end

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end
end