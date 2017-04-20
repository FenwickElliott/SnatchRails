class User < ApplicationRecord
  require 'json'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :initiate_settings
  before_create :generate_auth_token

  def initiate_settings
    self.settings ||= {p_name: "Snatched"}.to_json
  end

  def generate_auth_token
    loop do
      self.auth_token = SecureRandom.base64(64)
      break unless User.find_by(auth_token: auth_token)
    end
  end
end
