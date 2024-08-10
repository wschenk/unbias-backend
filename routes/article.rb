# routes/posts.rb
require_relative '../models/article'

get '/articles' do
  token = extract_token_from_header

  puts "token: #{token}"
  if token
    begin
      decoded_token = Clerk::SDK.new.verify_token(token)
      user_id = decoded_token['sub']
      puts "JWT token found: #{user_id}"
    rescue JWT::DecodeError
      puts 'Invalid JWT token'
    end
  end

  Article.all.order(created_at: :desc).limit(20).to_json
end

get '/article/:id' do
  article = Article.find(params[:id])
  article.process if article.state == 'new'
  Article.find(params[:id]).to_json
end

post '/article' do
  auth_check do |account|
    data = JSON.parse(request.body.read).symbolize_keys
    article = Article.new(account_id: account.id, state: 'new', url: data[:url], body: data[:body])
    if article.save
      article.process
      article.to_json
    else
      article.errors.to_json
    end
  end
end
