class User < ApplicationRecord
  require 'json'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :initiate_settings

  def initiate_settings
    self.settings ||= {p_name: "Snatched"}.to_json
  end
end
