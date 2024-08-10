class Llm < ActiveRecord::Migration[7.1]
  def change
    create_table :llms do |t|
      t.string :last_name
      t.string :access_key
    end
  end
end
