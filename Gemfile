# A sample Gemfile
source "https://rubygems.org"

group :production do
  gem 'pg'
end
group :development, :test do
  gem "sqlite3", groups: %w(test development), require: false
end
gem "activerecord"
gem "sinatra", git: 'https://github.com/juanpastas/sinatra.git'
gem "sinatra-contrib", git: 'https://github.com/sinatra/sinatra-contrib.git'
gem "haml"
gem "composite_primary_keys"
