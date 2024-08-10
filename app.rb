# app.rb
require 'dotenv/load'
require 'sinatra'
require 'sinatra/activerecord'
require_relative 'routes/account'
require_relative 'routes/article'
require_relative 'models/llm'
require 'jwt'
require 'clerk'

if ENV['APP_ENV'] == 'production' && ENV['RUNNING_MIGRATIONS'] != 'true'
  ENV['RUNNING_MIGRATIONS'] = 'true'
  puts 'Running migrate'
  system('bundle exec rake db:migrate')
end
# For cookies
use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           secret: 'sosecret'

set :default_content_type, :json

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
  response.headers['Access-Control-Allow-Methods'] =
    'GET, POST, PUT, DELETE, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] =
    'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token'
end

options '*' do
  response.headers['Allow'] = 'GET, POST, PUT, DELETE, OPTIONS'
  200
end

get '/' do
  { message: 'Hello world.' }.to_json
end

get '/up' do
  { success: true }.to_json
end

get '/private' do
  auth_check do
    { message: 'This is a private message.' }.to_json
  end
end

def auth_check
  token = extract_token_from_header

  if token
    begin
      decoded_token = Clerk::SDK.new.verify_token(token)
      user_id = decoded_token['sub']
      puts "JWT token found: #{user_id}"

      account = Account.from_clerk_id(user_id)
      # account.update_from_clerk
      return yield(account)
    rescue JWT::DecodeError
      puts 'Invalid JWT token'
    end
  end

  halt 403, { access: :denied }.to_json
end

def extract_token_from_header
  auth_header = request.env['HTTP_AUTHORIZATION']
  auth_header&.start_with?('Bearer ') ? auth_header.split(' ').last : nil
end
