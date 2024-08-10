class Account < ActiveRecord::Base
  def self.from_clerk_id(user_id)
    puts "user_id: #{user_id}"
    account = Account.where(user_id:).first_or_create
    account.update_from_clerk if account.email.nil? || account.email.empty?
    account
  end

  def after_create
    puts "account created: #{to_json}"
    update_from_clerk
  end

  def update_from_clerk
    clerk = Clerk::SDK.new

    user = clerk.users.find(user_id)

    self.email = user['email_addresses'][0]['email_address']
    self.first_name = user['first_name']
    self.last_name = user['last_name']

    save
  end
end
