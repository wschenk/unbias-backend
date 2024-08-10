# routes/posts.rb
require_relative '../models/account'

get '/account' do
  auth_check do
    Account.all.to_json
  end
end
