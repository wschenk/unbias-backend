# sinatra-ar-template

I wanted to setup a quick template for an API server using sinatra
and ActiveRecord, so I could throw something together but have
database migrations.

Here's a way to create something quickly.

[Original Blog Post]([https://willschenk.com/labnotes/2023/sinatra_with_activerecord/)

Code here has been slightly updated.

## Usage

```bash
git clone https://github.com/wschenk/sinatra-ar-template
```

### Create the database

```bash
rake db:migrate
```

### Start the server

```bash
rake dev
```

### Test

```bash
curl http://127.0.0.1:9292/ | jq .
{
  "message": "Hello world."
}
```

```bash
curl --cookie cookies.txt --cookie-jar cookies.txt http://127.0.0.1:9292/private
{
  "access": "denied"
}
```

### Create a user

```bash
curl -d 'name=will&password=password&password_confirmation=password' \
    --cookie cookies.txt --cookie-jar cookies.txt \
    http://127.0.0.1:9292/signup
```

### Login

```bash
curl --cookie cookies.txt --cookie-jar cookies.txt \
    -d 'name=will&password=password' \
    http://127.0.0.1:9292/login | jq .
```

### Check login

```bash
curl --cookie cookies.txt --cookie-jar cookies.txt \
  http://127.0.0.1:9292/private | jq .
```

## Adding models

```bash
rake db:create_migration NAME=create_comments
```

And create a migration like

```ruby
class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.references :post
      t.references :account
      t.text :body
      t.timestamps
    end
  end
end
```

Then create `models/comment.rb`

```ruby
class Comment < ActiveRecord::Base
  belongs_to :account
  belongs_to :post
end
```

Then create `routes/comment.rb`

```ruby
# routes/posts.rb
require_relative '../models/comment'

get '/comments' do
  auth_check do
    Comment.all.to_json
  end
end

post '/comments' do
  auth_check do
    c = Comment.new(body: params[:body])
    if c.save
      c.to_json
    else
      c.errors.to_json
    end
  end
end
```

And finally add those routes to the main `app.rb`

```ruby
require_relative 'routes/comments'
```

## Code overview

### 1. Application Setup:

The main application is defined in app.rb, which sets up Sinatra and ActiveRecord.

- It uses a SQLite database for development (configured in config/database.yml).

- The application is containerized using Docker (defined in Dockerfile).

### 2. Models:

- There are two main models: Post and Account.
- The Post model (models/post.rb) represents blog posts with name and body fields.
- The Account model (models/account.rb) handles user accounts with secure password authentication.

### 3. Routes:

- Post-related routes (routes/posts.rb):
  ** GET /posts: Retrieves all posts.
  ** POST /posts: Creates a new post.
- Account-related routes (routes/account.rb):
  ** POST /signup: Creates a new user account.
  ** POST /login: Authenticates a user and creates a session.
  \*\* GET /private: A protected route that requires authentication.

## 4. Database Migrations:

- The repository includes migrations for creating the posts and accounts tables.

## 5. Development Tools:

- The Rakefile includes tasks for running the development server and building the Docker image.
- It also includes ActiveRecord rake tasks for database management.

## 6. Authentication:

- The application uses BCrypt for password hashing.
- Session-based authentication is implemented using Rack::Session::Cookie.

## 7. API Format:

- The application is set up to return JSON responses by default.

This setup provides a foundation for building a simple JSON API with user authentication, ideal for small projects or as a starting point for more complex applications.

```

```
