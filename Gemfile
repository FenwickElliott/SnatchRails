source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails'

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

group :development do
  gem 'sqlite3'
  gem 'listen'
end

gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'bootstrap-sass'
gem 'omniauth-spotify-oauth2'
gem 'json'
gem 'figaro'
gem 'devise'