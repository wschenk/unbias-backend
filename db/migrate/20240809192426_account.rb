class Account < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :user_id
      t.string :email
      t.string :first_name
      t.string :last_name
      t.timestamps
    end
  end
end
