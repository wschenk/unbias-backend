require 'sinatra'
require 'sinatra/activerecord'

class Article < ActiveRecord::Base
  validates_presence_of :account_id, :url, :state

  def process
    Thread.new do
      self.state = 'loading'
      save
      self.body = IO.popen(['./load_url', url]).read
      self.state = 'parsing'
      save
      self.summary = IO.popen(['./summarize'], 'r+') do |pipe|
        pipe.puts body
        pipe.close_write
        pipe.read
      end
      self.state = 'done'
      save
    end
  end
end
