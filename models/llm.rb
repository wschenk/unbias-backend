class Llm < ActiveRecord::Base
  validates_presence_of :last_name, :access_key
end
